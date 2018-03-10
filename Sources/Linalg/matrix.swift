import Foundation
import Util

public protocol Matrix: Composite {
    var transposed: Self { get }

    static var identity: Self { get }

    static func *(left: Self, right: Self) -> Self
    static func *(left: Self, right: ComponentType) -> ComponentType
}

public extension Matrix {
    static func *(left: ComponentType, right: Self) -> ComponentType {
        return right.transposed * left
    }
}

public struct Matrix2: Matrix, Composite2 {
    public let x, y: Vector2

    // See https://bugs.swift.org/browse/SR-3003
    public init(_ x: Vector2, _ y: Vector2) {
        self.x = x
        self.y = y
    }

    public init(withRotationOfAngle: Double) {
        self.init(
            Vector2(cos(withRotationOfAngle), -sin(withRotationOfAngle)),
            Vector2(sin(withRotationOfAngle), cos(withRotationOfAngle)))
    }

    public var transposed: Matrix2 {
        return Matrix2(Vector2(x.x, y.x), Vector2(x.y, y.y))
    }

    public typealias ComponentType = Vector2

    public static let zero = Matrix2(Vector2.zero, Vector2.zero)
    public static let identity = Matrix2(Vector2(1, 0), Vector2(0, 1))

    public static func *(left: Matrix2, right: Matrix2) -> Matrix2 {
        return Matrix2(left.x * right, left.y * right)
    }

    public static func *(left: Matrix2, right: Vector2) -> Vector2 {
        return Vector2(left.x * right, left.y * right)
    }
}

public struct Matrix3: Matrix, Composite3 {
    public let x, y, z: Vector3

    public init(_ x: Vector3, _ y: Vector3, _ z: Vector3) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(withRotationOfAngle angle: Double, aroundAxis axis: Vector3) {
        let normalizedAxis = axis.normalized
        let x = normalizedAxis.x
        let y = normalizedAxis.y
        let z = normalizedAxis.z
        let c = cos(angle)
        let s = sin(angle)
        let f1: (Double, Double, Double) -> Double = { $0 * $0 + c * ($1 * $1 + $2 * $2) }
        let f2: (Double, Double, Double) -> Double = { s * $0 + (1 - c) * $1 * $2 }

        self.init(
            Vector3(f1(x, y, z), f2(-z, x, y), f2(y, z, x)),
            Vector3(f2(z, x, y), f1(y, z, x), f2(-x, y, z)),
            Vector3(f2(-y, z, x), f2(x, y, z), f1(z, x, y)))
    }

    public var transposed: Matrix3 {
        return Matrix3(Vector3(x.x, y.x, z.x), Vector3(x.y, y.y, z.y), Vector3(x.y, y.y, z.z))
    }

    public typealias ComponentType = Vector3

    public static let zero = Matrix3(Vector3.zero, Vector3.zero, Vector3.zero)
    public static let identity = Matrix3(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))

    public static func *(left: Matrix3, right: Matrix3) -> Matrix3 {
        return Matrix3(left.x * right, left.y * right, left.z * right)
    }

    public static func *(left: Matrix3, right: Vector3) -> Vector3 {
        return Vector3(left.x * right, left.y * right, left.z * right)
    }
}

