import Foundation
import Linalg

public struct IsoPoint2 {
    let value: Double
    let derivative: Vector2
}

public struct IsoRegion2 {
    fileprivate let evaluateFn: (Vector2) -> IsoPoint2

    init(_ evaluateFn: @escaping (_ atCoordinate: Vector2) -> IsoPoint2) {
        self.evaluateFn = evaluateFn
    }

    func evaluate(atCoordinate: Vector2) -> IsoPoint2 {
        return evaluateFn(atCoordinate)
    }
}
