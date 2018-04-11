import Foundation
import Linalg

public typealias IsoPoint<C: Vector> = (value: Double, derivative: C)

public protocol IsoRegionProtocol {
    associatedtype CoordinateType: Vector

    typealias Point = IsoPoint<CoordinateType>

    init(_: @escaping (CoordinateType) -> Point)

    func evaluateAt(_ coordinate: CoordinateType) -> Point;
}

public struct IsoRegion<C: Vector> {
    public typealias CoordinateType = C

    private let evaluateFn: (CoordinateType) -> Point
}

extension IsoRegion: IsoRegionProtocol {
    public init(_ evaluateFn: @escaping (CoordinateType) -> Point) {
        self.evaluateFn = evaluateFn
    }

    public func evaluateAt(_ coordinate: CoordinateType) -> Point {
        return evaluateFn(coordinate)
    }
}

public typealias IsoRegion1 = IsoRegion<Vector1>
public typealias IsoRegion2 = IsoRegion<Vector2>
public typealias IsoRegion3 = IsoRegion<Vector3>
