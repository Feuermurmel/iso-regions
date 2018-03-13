import XCTest
import Linalg
import IsoRegions
import Util

extension Shape where Boundary == Boundary2D {
    var area: Double {
        let twiceArea = self.boundary.lazy
            .map({ boundary in
                let x1 = boundary.vertex1.x
                let y1 = boundary.vertex1.y
                let x2 = boundary.vertex2.x
                let y2 = boundary.vertex2.y

                return (x1 - x2) * (y1 + y2) })
            .reduce(0.0, +)

        return twiceArea / 2
    }
}

class UnitTests: XCTestCase {
    func testBoundaryConsistency() {
        func checkBoundaryConsistency(_ object: Shape2D) {
            var segmentsByVertex: [Vector2: (incoming: Int, outgoing: Int)] = [:]

            for i in object.boundary {
                segmentsByVertex[i.vertex1, default: (0, 0)].outgoing += 1
                segmentsByVertex[i.vertex2, default: (0, 0)].incoming += 1
            }

            for (v, s) in segmentsByVertex {
                XCTAssertEqual(s.incoming, s.outgoing, "\(v)")
            }
        }

        checkBoundaryConsistency(render(region: circle(radius: 0.5), resolution: 1))
        checkBoundaryConsistency(render(region: circle(radius: 1), resolution: 0.1))
        checkBoundaryConsistency(
            render(region: circle(radius: 1) | circle(radius: 1).move(x: 1), resolution: 0.1))
    }

    func testRenderedObjectArea() {
        func checkArea(_ region: IsoRegion2, _ area: Double) {
            let object = render(region: region, resolution: 0.1)

            XCTAssertEqual(object.area, area, accuracy: 0.1)
        }

        checkArea(circle(radius: 1), Double.tau / 2)

        checkArea(
            circle(radius: 1) | circle(radius: 1).move(x: 1),
            (3 * sqrt(3) + 4 * Double.tau) / 6)
    }
}

