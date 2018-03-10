import Foundation
import Linalg

public struct IsoRegion2 {
    public typealias Point = (value: Double, derivative: Vector2)

    private let evaluateFn: (Vector2) -> Point

    init(_ evaluateFn: @escaping (_ atCoordinate: Vector2) -> Point) {
        self.evaluateFn = evaluateFn
    }

    func evaluate(atCoordinate: Vector2) -> Point {
        return evaluateFn(atCoordinate)
    }
}
