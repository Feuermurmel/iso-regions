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

public let cornerJoin = fillet(0)

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

public struct RegionWithJoinInfo<R: IsoRegionProtocol> {
    let region: R
    let joinInfo: JoinInfo
}

public protocol JoinArgument {
    associatedtype RegionType: IsoRegionProtocol

    var regionWithJoinInfo: RegionWithJoinInfo<RegionType> { get }
}

extension RegionWithJoinInfo: JoinArgument {
    public typealias RegionType = R

    public var regionWithJoinInfo: RegionWithJoinInfo {
        return self
    }
}

extension IsoRegion: JoinArgument {
    public typealias RegionType = IsoRegion<CoordinateType>

    public var regionWithJoinInfo: RegionWithJoinInfo<RegionType> {
        return RegionWithJoinInfo(region: self, joinInfo: cornerJoin)
    }
}

public extension IsoRegionProtocol {
    func move(_ offset: CoordinateType) -> Self {
        return translation(offset: offset, self)
    }

    func scale(_ factor: Double, origin: CoordinateType = .zero) -> Self {
        return scaling(factor: factor, self)
    }

    func mirror(direction: CoordinateType, origin: CoordinateType = .zero) -> Self {
        return transform(self, withOrigin: origin, mirroring)
    }

    static func << (left: Self, right: Double) -> Self {
        return dilation(distance: right, left)
    }

    static func <<= (left: inout Self, right: Double) {
        left = left << right
    }

    static func >> (left: Self, right: Double) -> Self {
        return left << -right
    }

    static func >>= (left: inout Self, right: Double) {
        left = left >> right
    }

    static prefix func ~ (value: Self) -> Self {
        return inversion(value)
    }

    static func %% (left: Self, right: JoinInfoArgument) -> RegionWithJoinInfo<Self> {
        let x = RegionWithJoinInfo(region: left, joinInfo: right.joinInfo)
        return x
    }

    static func & <J: JoinArgument>(left: Self, right: J) -> Self where J.RegionType == Self {
        let region = right.regionWithJoinInfo.region
        let joinInfo = right.regionWithJoinInfo.joinInfo

        return intersection(type: joinInfo.type, left >> joinInfo.radius, region >> joinInfo.radius) << joinInfo.radius
    }

    static func &= <J: JoinArgument>(left: inout Self, right: J) where J.RegionType == Self {
        left = left & right
    }

    static func | <J: JoinArgument>(left: Self, right: J) -> Self where J.RegionType == Self {
        return ~(~left & ~right.regionWithJoinInfo.region %% right.regionWithJoinInfo.joinInfo)
    }

    static func |= <J: JoinArgument>(left: inout Self, right: J) where J.RegionType == Self {
        left = left | right
    }

    static func / <J: JoinArgument>(left: Self, right: J) -> Self where J.RegionType == Self {
        return left & ~right.regionWithJoinInfo.region %% right.regionWithJoinInfo.joinInfo
    }

    static func /= <J: JoinArgument>(left: inout Self, right: J) where J.RegionType == Self {
        left = left / right
    }
}

public extension IsoRegionProtocol where CoordinateType == Vector1 {
    func move(x: Double = 0) -> Self {
        return move(Vector1(x))
    }

    func mirror(origin: Double = 0) -> Self {
        return self.mirror(direction: Vector1(1), origin: Vector1(origin))
    }
}

public extension IsoRegionProtocol where CoordinateType == Vector2 {
    func move(x: Double = 0, y: Double = 0) -> Self {
        return move(Vector2(x, y))
    }

    func rotate(_ angle: Double, origin: Vector2 = Vector2.zero) -> Self {
        return transform(self, withOrigin: origin) { rotation(angle: angle, $0) }
    }
}

public extension IsoRegionProtocol where CoordinateType == Vector3 {
    func move(x: Double = 0, y: Double = 0, z: Double = 0) -> Self {
        return move(Vector3(x, y, z))
    }

    func rotated(_ angle: Double, axis: Vector3, origin: Vector3 = Vector3.zero) -> Self {
        return transform(self, withOrigin: origin) { rotation($0, angle: angle, axis: axis) }
    }

    func rotated(x: Double, y: Double, z: Double, origin: Vector3 = Vector3.zero) -> Self {
        return transform(self, withOrigin: origin) {
            return $0
                .rotated(x, axis: Vector3(1, 0, 0))
                .rotated(y, axis: Vector3(0, 1, 0))
                .rotated(z, axis: Vector3(0, 0, 1))
        }
    }
}

public extension Array where Element: IsoRegionProtocol {
    public func union(joinInfo: JoinInfoArgument = cornerJoin) -> Element {
        return self.reduce(void()) { $0 | $1 %% joinInfo }
    }

    public func intersection(joinInfo: JoinInfoArgument = cornerJoin) -> Element {
        return self.reduce(void()) { $0 & $1 %% joinInfo }
    }
}

func zeroOffsetOperation<R: IsoRegionProtocol>(_ region: R, operation: @escaping (R.Point) -> R.Point) -> R {
    return R { coordinate in
        return operation(region.evaluateAt(coordinate))
    }
}

func pointWithLargerValue<C: Vector>(_ point1: IsoPoint<C>, _ point2: IsoPoint<C>) -> IsoPoint<C> {
    if point1.value > point2.value {
        return point1
    } else {
        return point2
    }
}

fileprivate func transform<R: IsoRegionProtocol>(_ region: R, withOrigin origin: R.CoordinateType, _ operation: (R) -> R) -> R {
    return operation(region.move(-origin)).move(origin)
}

func tube(radius: Double, _ region1: IsoRegion2, _ region2: IsoRegion2) -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        let point1 = region1.evaluateAt(coordinate)
        let point2 = region2.evaluateAt(coordinate)
        let filletPoint = filletShape(point1, point2).point

        return (filletPoint.value - radius, filletPoint.derivative)
    }
}

fileprivate func filletShape<C: Vector>(_ point1: IsoPoint<C>, _ point2: IsoPoint<C>) -> (inside: Bool, point: IsoPoint<C>) {
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

fileprivate func translation<R: IsoRegionProtocol>(offset: R.CoordinateType, _ region: R) -> R {
    if offset == R.CoordinateType.zero {
        return region
    }

    return R { coordinate in
        return region.evaluateAt(coordinate - offset)
    }
}

fileprivate func rotation<R: IsoRegionProtocol>(angle: Double, _ region: R) -> R where R.CoordinateType == Vector2 {
    if angle == 0 {
        return region
    }

    let rotationMatrix = Matrix2(withRotationOfAngle: angle)
    let inverseRotationMatrix = Matrix2(withRotationOfAngle: -angle)

    return R { coordinate in
        let point = region.evaluateAt(inverseRotationMatrix * coordinate)

        return (point.value, rotationMatrix * point.derivative)
    }
}

fileprivate func rotation<R: IsoRegionProtocol>(_ region: R, angle: Double, axis: Vector3) -> R where R.CoordinateType == Vector3 {
    if angle == 0 {
        return region
    }

    let rotationMatrix = Matrix3(withRotationOfAngle: angle, aroundAxis: axis)
    let inverseRotationMatrix = Matrix3(withRotationOfAngle: -angle, aroundAxis: axis)

    return R { coordinate in
        let point = region.evaluateAt(inverseRotationMatrix * coordinate)

        return (point.value, rotationMatrix * point.derivative)
    }
}

fileprivate func mirroring<R: IsoRegionProtocol>(region: R) -> R {
    return R { coordinate in
        let point = region.evaluateAt(-coordinate)

        return (point.value, -point.derivative)
    }
}

fileprivate func scaling<R: IsoRegionProtocol>(factor: Double, _ region: R) -> R {
    precondition(factor != 0, "`factor` cannot be zero")

    if factor == 1 {
        return region
    }

    return R { coordinate in
        let point = region.evaluateAt(coordinate / factor)

        return (
            point.value * factor.magnitude,
            point.derivative * Double(signOf: factor, magnitudeOf: 1))
    }
}

fileprivate func dilation<R: IsoRegionProtocol>(distance: Double, _ region: R) -> R {
    // We implicitly generate dilation operations when joining regions which default to a distance of 0.
    if distance == 0 {
        return region
    }

    return zeroOffsetOperation(region) { point in
        return (point.value - distance, point.derivative)
    }
}

fileprivate func inversion<R: IsoRegionProtocol>(_ region: R) -> R {
    return zeroOffsetOperation(region) { point in
        return (-point.value, -point.derivative)
    }
}

fileprivate func intersection<R: IsoRegionProtocol>(type: JoinType, _ region1: R, _ region2: R) -> R {
    switch type {
    case .fillet:
        return R { coordinate in
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
        return R { coordinate in
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
