import Foundation
import Util
import Linalg

fileprivate struct Grid2D {
    let origin: Vector2
    let spacing: Double

    subscript(index: GridIndex) -> Vector2 {
        return origin + Vector2(Double(index.x), Double(index.y)) * spacing
    }
}

fileprivate struct GridIndex {
    let x: Int
    let y: Int

    var isOdd: Bool {
        return (x + y) % 2 != 0
    }

    func moved(x: Int, y: Int) -> GridIndex {
        return GridIndex(x: self.x + x, y: self.y + y)
    }
}

extension GridIndex: Hashable {
    var hashValue: Int {
        return hashItems(x, y)
    }

    static func ==(lhs: GridIndex, rhs: GridIndex) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

fileprivate extension Array {
    mutating func append(optionalElement: Element?) {
        if let element = optionalElement {
            self.append(element)
        }
    }
}

fileprivate struct RegionPoint {
    let coordinate: Vector2
    let value: Double

    var inside: Bool {
        return value < 0
    }
}

fileprivate func intersection(_ point1: RegionPoint, _ point2: RegionPoint) -> Vector2 {
    let result: Vector2 = (point2.coordinate * point1.value - point1.coordinate * point2.value) / (point1.value - point2.value)

    precondition(result.x.isFinite && result.y.isFinite)

    return result
}

/// Process a triangle. The points are given in positive winding order.
fileprivate func triangle(_ point1: RegionPoint, _ point2: RegionPoint, _ point3: RegionPoint) -> Boundary2D? {
    let parity = point1.inside
    // The corner of the triangle that is on the other side of the bounary relative to the other two points.
    let focusCorner: RegionPoint
    // The two other corners, each touching one side of the triangle that delimits the boundary.
    var startCorner, endCorner: RegionPoint

    switch (point2.inside != parity, point3.inside != parity) {
    case (false, false):
        return nil
    case (false, true):
        focusCorner = point3
        startCorner = point1
        endCorner = point2
    case (true, false):
        focusCorner = point2
        startCorner = point3
        endCorner = point1
    case (true, true):
        focusCorner = point1
        startCorner = point3
        endCorner = point2
    }

    if parity {
        swap(&startCorner, &endCorner)
    }

    return Boundary2D(
        vertex1: intersection(focusCorner, startCorner),
        vertex2: intersection(focusCorner, endCorner))
}

fileprivate func render(region: IsoRegion2, grid: Grid2D, levels: Int) -> Object2D {
    let progressIndicator: ProgressIndicator = createProgressIndicator()

    var boundaries: [Boundary2D] = []

    var regionPointsByIndex: [GridIndex:Double] = [:]

    // Keeps track of all indices which already have been added to indexesToProcess to avoid processing the same index twice.
    var visitedIndices: Set<GridIndex> = []

    // Queue of indices which still need to be visited.
    var indicesToProcess: [GridIndex] = []

    var progressStep = 0

    func printProgress() {
        progressStep += 1

        if progressStep == 200 {
            progressIndicator.setProgress("\(visitedIndices.count - indicesToProcess.count) / \(visitedIndices.count)")
            progressStep = 0
        }
    }

    func getRegionPoint(index: GridIndex) -> RegionPoint {
        let coordinate = grid[index]

        let value = regionPointsByIndex[
            index,
            default: region.evaluate(atCoordinate: coordinate).value]

        return RegionPoint(coordinate: coordinate, value: value)
    }

    func visitGridIndex(_ index: GridIndex) {
        if !visitedIndices.contains(index) {
            visitedIndices.insert(index)
            indicesToProcess.append(index)
        }
    }

    func walkQuadrant(index: GridIndex, level: Int) {
        if (level > 0) {
            let newLevel = level - 1
            let halfCount = 1 << newLevel
            let centerIndex = index.moved(x: halfCount, y: halfCount)
            let centerPoint = getRegionPoint(index: centerIndex)

            if centerPoint.value.magnitude <= sqrt(2) * Double(halfCount) * grid.spacing * 1.01 {
                for iy in [0, 1] {
                    for ix in [0, 1] {
                        let newIndex = index.moved(x: halfCount * ix, y: halfCount * iy)

                        walkQuadrant(index: newIndex, level: newLevel)
                    }
                }
            }
        } else {
            visitGridIndex(index)
            printProgress()
        }
    }

    func processGridIndex(_ index: GridIndex) {
        func processTriangle(_ p1: RegionPoint, _ p2: RegionPoint, _ p3: RegionPoint) {
            boundaries.append(optionalElement: triangle(p1, p2, p3))
        }

        func processInterface(_ point1: RegionPoint, _ point2: RegionPoint, _ offsetx: Int, _ offsety: Int) {
            if point1.inside != point2.inside {
                visitGridIndex(index.moved(x: offsetx, y: offsety))
            }
        }

        let point00 = getRegionPoint(index: index.moved(x: 0, y: 0))
        let point01 = getRegionPoint(index: index.moved(x: 0, y: 1))
        let point10 = getRegionPoint(index: index.moved(x: 1, y: 0))
        let point11 = getRegionPoint(index: index.moved(x: 1, y: 1))

        // We mirror the element's triangulation for every other element. This is especially important for the 3D case to get edges introduced on the cubes' faces to align for adjacent cubes.
        if index.isOdd {
            processTriangle(point00, point10, point11)
            processTriangle(point00, point11, point01)
        } else {
            processTriangle(point00, point10, point01)
            processTriangle(point01, point10, point11)
        }

        processInterface(point00, point01, -1, 0)
        processInterface(point10, point11, 1, 0)
        processInterface(point00, point10, 0, -1)
        processInterface(point01, point11, 0, 1)
    }

    walkQuadrant(index: GridIndex(x: 0, y: 0), level: levels)

    while let index = indicesToProcess.popLast() {
        processGridIndex(index)
        printProgress()
    }

    log("Search grid has \(1 << (2 * levels)) indices. \(visitedIndices.count) indices have been visited.")

    return Object2D(boundary: boundaries)
}

public func render(region: IsoRegion2, resolution: Double, searchCenter: Vector2 = Vector2.zero, searchRange: Double = 1e6) -> Object2D {
    let grid = Grid2D(origin: searchCenter - Vector2(1, 1) * searchRange / 2, spacing: resolution)
    let levels = Int(exactly: log2(searchRange / resolution).rounded(.up))!

    return render(region: region, grid: grid, levels: levels)
}
