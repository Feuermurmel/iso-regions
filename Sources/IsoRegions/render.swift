import Foundation

fileprivate struct Grid2D {
    let origin: Vector2
    let spacing: Double
    
    subscript(index: GridIndex) -> Vector2 {
        return origin + Vector2(Double(index.x), Double(index.y)) * spacing
    }
}

fileprivate struct GridIndex: EasyHashable {
    let x: Int
    let y: Int
    
    static var hashableProperties = defineHashableProperties({ $0.x }, { $0.y })
    
    var parity: Int {
        return (x + y) % 2
    }
    
    func moved(x: Int, y: Int) -> GridIndex {
        return GridIndex(x: self.x + x, y: self.y + y)
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
}

fileprivate func intersection(_ point1: RegionPoint, _ point2: RegionPoint) -> Vector2? {
    if (point1.value < 0) != (point2.value < 0) {
        let result: Vector2 = (point2.coordinate * point1.value - point1.coordinate * point2.value) / (point1.value - point2.value)
        
        precondition(result.x.isFinite && result.y.isFinite)
        
        return result
    } else {
        return nil
    }
}

fileprivate func triangle(_ intersection1: Vector2?, _ intersection2: Vector2?, _ intersection3: Vector2?) -> Boundary2D? {
    var intersections: [Vector2] = [intersection1, intersection2, intersection3].flatMap { $0 }
    
    if intersections.count == 0 {
        return nil
    } else if (intersections.count == 2) {
        return Boundary2D(vertex1: intersections[0], vertex2: intersections[1])
    } else {
        preconditionFailure(
            "Number of sign-flipping edges (\(intersections.count)) is neither 0 nor 2")
    }
}

fileprivate func render(region: IsoRegion2, grid: Grid2D, levels: Int) -> Object2D {
    let progressIndicator: ProgressIndicator = createProgressIndicator()
    
    var boundaries: [Boundary2D] = []
    
    var regionPointsByIndex: [GridIndex:Double] = [:]
    
    // Keeps track of all indices which already have been added to indexesToProcess to avoid processing the same index twice.
    var visitedIndices: Set<GridIndex> = []
    
    // Queue of indices which still need to be visited.
    var indicesToProcess: [GridIndex] = []
    
    func printProgress() {
        progressIndicator.setProgress("\(visitedIndices.count - indicesToProcess.count) / \(visitedIndices.count)")
    }
    
    func getRegionPoint(index: GridIndex) -> RegionPoint {
        let coordinate = grid[index]
        
        let value = regionPointsByIndex.getOrUpdate(
            index,
            computeValue: region.evaluate(atCoordinate: coordinate).value)
        
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
        func processTriangle(_ i1: Vector2?, _ i2: Vector2?, _ i3: Vector2?) {
            boundaries.append(optionalElement: triangle(i1, i2, i3))
        }
        
        func processInterface(_ intersection: Vector2?, _ offsetx: Int, _ offsety: Int) {
            if intersection != nil {
                visitGridIndex(index.moved(x: offsetx, y: offsety))
            }
        }
        
        // We flip the element's triangulation in the y direction for every other element. This is especially important for the 3D case to get edges introduced on the cubes' faces to align for adjacent cubes.
        let parity = index.parity
        
        let point00 = getRegionPoint(index: index.moved(x: 0, y: parity))
        let point01 = getRegionPoint(index: index.moved(x: 0, y: 1 - parity))
        let point10 = getRegionPoint(index: index.moved(x: 1, y: parity))
        let point11 = getRegionPoint(index: index.moved(x: 1, y: 1 - parity))
        
        let intersection00to01 = intersection(point00, point01)
        let intersection00to10 = intersection(point00, point10)
        let intersection01to10 = intersection(point01, point10)
        let intersection01to11 = intersection(point01, point11)
        let intersection10to11 = intersection(point10, point11)
        
        processTriangle(intersection00to10, intersection01to10, intersection00to01)
        processTriangle(intersection01to11, intersection01to10, intersection10to11)
        
        processInterface(intersection00to01, -1, 0)
        processInterface(intersection10to11, 1, 0)
        processInterface(intersection00to10, 0, parity * 2 - 1)
        processInterface(intersection01to11, 0, 1 - parity * 2)
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
