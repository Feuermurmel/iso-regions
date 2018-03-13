import Foundation
import Linalg

infix operator %%: BitwiseShiftPrecedence

enum JoinType {
    case fillet
    case chamfer
}

public struct JoinInfo {
    let radius: Double
    let type: JoinType
}

public func fillet(_ radius: Double) -> JoinInfo {
    return JoinInfo(radius: radius, type: .fillet)
}

public func chamfer(_ radius: Double) -> JoinInfo {
    return JoinInfo(radius: radius, type: .chamfer)
}

fileprivate let cornerJoin = fillet(0)

public protocol JoinInfoArgument {
    var joinInfo: JoinInfo { get }
}

extension JoinInfo: JoinInfoArgument {
    public var joinInfo: JoinInfo {
        return self
    }
}

extension Double: JoinInfoArgument {
    public var joinInfo: JoinInfo {
        return JoinInfo(radius: self, type: .fillet)
    }
}

public struct RegionWithJoinInfo {
    let region: IsoRegion2
    let joinInfo: JoinInfo
}

public protocol JoinArgument {
    var regionWithJoinInfo: RegionWithJoinInfo { get }
}

extension RegionWithJoinInfo: JoinArgument {
    public var regionWithJoinInfo: RegionWithJoinInfo {
        return self
    }
}

extension IsoRegion2: JoinArgument {
    public var regionWithJoinInfo: RegionWithJoinInfo {
        return RegionWithJoinInfo(region: self, joinInfo: cornerJoin)
    }
}

public extension IsoRegion2 {
    func move(x: Double = 0, y: Double = 0) -> IsoRegion2 {
        return move(Vector2(x, y))
    }

    func move(_ offset: Vector2) -> IsoRegion2 {
        return translation(offset: offset, self)
    }

    func rotate(_ angle: Double, origin: Vector2 = Vector2.zero) -> IsoRegion2 {
        return rotation(angle: angle, self)
    }

    func scale(_ factor: Double, origin: Vector2 = Vector2.zero) -> IsoRegion2 {
        return scaling(factor: factor, self)
    }

    static func <<(left: IsoRegion2, right: Double) -> IsoRegion2 {
        return dilation(distance: right, left)
    }

    static func <<=(left: inout IsoRegion2, right: Double) {
        left = left << right
    }

    static func >>(left: IsoRegion2, right: Double) -> IsoRegion2 {
        return left << -right
    }

    static func >>=(left: inout IsoRegion2, right: Double) {
        left = left >> right
    }

    static prefix func ~(value: IsoRegion2) -> IsoRegion2 {
        return inversion(value)
    }

    static func %%(left: IsoRegion2, right: JoinInfoArgument) -> RegionWithJoinInfo {
        return RegionWithJoinInfo(region: left, joinInfo: right.joinInfo)
    }

    static func &(left: IsoRegion2, right: JoinArgument) -> IsoRegion2 {
        let region = right.regionWithJoinInfo.region
        let joinInfo: JoinInfo = right.regionWithJoinInfo.joinInfo

        return intersection(type: joinInfo.type, left >> joinInfo.radius, region >> joinInfo.radius) << joinInfo.radius
    }

    static func &=(left: inout IsoRegion2, right: JoinArgument) {
        left = left & right
    }

    static func |(left: IsoRegion2, right: JoinArgument) -> IsoRegion2 {
        return ~(~left & ~right.regionWithJoinInfo.region %% right.regionWithJoinInfo.joinInfo)
    }

    static func |=(left: inout IsoRegion2, right: JoinArgument) {
        left = left | right
    }

    static func /(left: IsoRegion2, right: JoinArgument) -> IsoRegion2 {
        return left & ~right.regionWithJoinInfo.region %% right.regionWithJoinInfo.joinInfo
    }

    static func /=(left: inout IsoRegion2, right: JoinArgument) {
        left = left / right
    }
}

public extension Array where Element == IsoRegion2 {
    public func union(joinInfo: JoinInfoArgument) -> IsoRegion2 {
        return self.reduce(void()) { $0 | $1 %% joinInfo }
    }

    public func union() -> IsoRegion2 {
        return self.union(joinInfo: cornerJoin)
    }

    public func intersection(joinInfo: JoinInfoArgument) -> IsoRegion2 {
        return self.reduce(void()) { $0 & $1 %% joinInfo }
    }

    public func intersection() -> IsoRegion2 {
        return self.intersection(joinInfo: cornerJoin)
    }
}

func zeroOffsetOperation(_ region: IsoRegion2, operation: @escaping (IsoRegion2.Point) -> IsoRegion2.Point) -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        return operation(region.evaluateAt(  coordinate))
    }
}

func pointWithLargerValue(_ point1: IsoRegion2.Point, _ point2: IsoRegion2.Point) -> IsoRegion2.Point {
    if point1.value > point2.value {
        return point1
    } else {
        return point2
    }
}

func tube(radius: Double, _ region1: IsoRegion2, _ region2: IsoRegion2) -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        let point1 = region1.evaluateAt(coordinate)
        let point2 = region2.evaluateAt(coordinate)
        let filletPoint = filletShape(point1, point2).point

        return (filletPoint.value - radius, filletPoint.derivative)
    }
}

fileprivate func filletShape(_ point1: IsoRegion2.Point, _ point2: IsoRegion2.Point) -> (inside: Bool, point: IsoRegion2.Point) {
    let v1 = point1.value
    let v2 = point2.value
    let d1 = point1.derivative
    let d2 = point2.derivative

    let p = d1 * d2
    let pp = p * p - 1

    // swiftc: Expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
    let schnauz1 = v2 * d1 * p
    let schnauz2 = v1 * d2 * p
    let schnauz3 = v1 * d1
    let schnauz4 = v2 * d2
    let diniMueter = schnauz1 + schnauz2 - schnauz3 - schnauz4

    let inside = v1 * p - v2 < 0 && v2 * p - v1 < 0
    let a = sqrt((2 * v1 * v2 * p - v1 * v1 - v2 * v2) / pp)
    let d = diniMueter / a / pp

    return (inside, (a, d))
}

fileprivate func translation(offset: Vector2, _ region: IsoRegion2) -> IsoRegion2 {
    if offset == Vector2.zero {
        return region
    } else {
        return IsoRegion2 { coordinate in
            return region.evaluateAt(coordinate - offset)
        }
    }
}

fileprivate func rotation(angle: Double, _ region: IsoRegion2) -> IsoRegion2 {
    let rotationMatrix = Matrix2(withRotationOfAngle: angle)
    let inverseRotationMatrix = Matrix2(withRotationOfAngle: -angle)

    if (angle == 0) {
        return region
    } else {
        return IsoRegion2 { coordinate in
            let point = region.evaluateAt(inverseRotationMatrix * coordinate)

            return (point.value, rotationMatrix * point.derivative)
        }
    }
}

fileprivate func scaling(factor: Double, _ region: IsoRegion2) -> IsoRegion2 {
    precondition(factor != 0, "`factor` cannot be zero")

    if (factor == 1) {
        return region
    } else {
        return IsoRegion2 { coordinate in
            let point = region.evaluateAt(coordinate / factor)
            let value = point.value * factor.magnitude
            let derivative = point.derivative * Double(signOf: factor, magnitudeOf: 1)

            return (value, derivative)
        }
    }
}

fileprivate func dilation(distance: Double, _ region: IsoRegion2) -> IsoRegion2 {
    // We implicitly generate dilation operations when joining regions which default to a distance of 0.
    if distance == 0 {
        return region
    } else {
        return zeroOffsetOperation(region) { point in
            return (point.value - distance, point.derivative)
        }
    }
}

fileprivate func inversion(_ region: IsoRegion2) -> IsoRegion2 {
    return zeroOffsetOperation(region) { point in
        return (-point.value, -point.derivative)
    }
}

fileprivate func intersection(type: JoinType, _ region1: IsoRegion2, _ region2: IsoRegion2) -> IsoRegion2 {
    switch type {
    case .fillet:
        return IsoRegion2 { coordinate in
            let point1 = region1.evaluateAt(coordinate)
            let point2 = region2.evaluateAt(coordinate)
            let fillet = filletShape(point1, point2)

            if fillet.inside {
                return fillet.point
            } else {
                return pointWithLargerValue(point1, point2)
            }
        }
    case .chamfer:
        return IsoRegion2 { coordinate in
            let point1 = region1.evaluateAt(coordinate)
            let point2 = region2.evaluateAt(coordinate)
            let derivativesSum = point1.derivative + point2.derivative
            let value = (point1.value + point2.value) / derivativesSum.norm

            return pointWithLargerValue(
                (value, derivativesSum.normalized),
                pointWithLargerValue(point1, point2))
        }
    }
}
