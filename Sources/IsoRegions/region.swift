import Foundation
import Linalg

public struct IsoRegion2 {
    public typealias Point = (value: Double, derivative: Vector2)

    private let evaluateFn: (Vector2) -> Point

    init(_ evaluateFn: @escaping (Vector2) -> Point) {
        self.evaluateFn = evaluateFn
    }

    func evaluateAt(_ coordinate: Vector2) -> Point {
        return evaluateFn(coordinate)
    }
}
