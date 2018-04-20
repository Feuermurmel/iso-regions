import Foundation
import Util

// TODO: Declare Matrix with "where ComponentType: Vector" once this isn't crashing swiftc anymore.
public protocol Matrix: Composite where ComponentType: Vector, ComponentType.CompatibleMatrix == Self {
    var transposed: Self { get }

    typealias CompatibleVector = ComponentType

    static var identity: Self { get }

    static func *(left: Self, right: Self) -> Self
    static func *(left: Self, right: ComponentType) -> ComponentType
}

public extension Matrix {
    static func *(left: ComponentType, right: Self) -> ComponentType {
        return right.transposed * left
    }
}

public struct Matrix0: Hashable {
    public init() {
    }
}

extension Matrix0: Group {
    public static let zero = Matrix0()
}

extension Matrix0: Composite0 {
    public var x: Vector0 {
        return .zero
    }

    public typealias ComponentType = Vector0
}

extension Matrix0: Matrix {
    public var transposed: Matrix0 {
        return self
    }

    public static let identity = Matrix0()

    public static func *(left: Matrix0, right: Matrix0) -> Matrix0 {
        return Matrix0()
    }

    public static func *(left: Matrix0, right: Vector0) -> Vector0 {
        return Vector0()
    }
}

public struct Matrix1: Hashable {
    public let x: Vector1
}

extension Matrix1: Group {
    public static let zero = Matrix1(Vector1.zero)
}

extension Matrix1: Composite1 {
    public init(_ x: Vector1) {
        self.x = x
    }

    public typealias ComponentType = Vector1
}

extension Matrix1: Matrix {
    public var transposed: Matrix1 {
        return self
    }

    public static let identity = Matrix1(Vector1(1))

    public static func *(left: Matrix1, right: Matrix1) -> Matrix1 {
        return Matrix1(left.x * right)
    }

    public static func *(left: Matrix1, right: Vector1) -> Vector1 {
        return Vector1(left.x * right)
    }
}

public struct Matrix2: Hashable {
    public let x, y: Vector2
}

public extension Matrix2 {
    public init(withRotationOfAngle: Double) {
        self.init(
            Vector2(cos(withRotationOfAngle), -sin(withRotationOfAngle)),
            Vector2(sin(withRotationOfAngle), cos(withRotationOfAngle)))
    }
}

extension Matrix2: Group {
    public static let zero = Matrix2(Vector2.zero, Vector2.zero)
}

extension Matrix2: Composite2 {
    // See https://bugs.swift.org/browse/SR-3003
    public init(_ x: Vector2, _ y: Vector2) {
        self.x = x
        self.y = y
    }

    public typealias ComponentType = Vector2
}

extension Matrix2: Matrix {
    public var transposed: Matrix2 {
        return Matrix2(Vector2(x.x, y.x), Vector2(x.y, y.y))
    }

    public static let identity = Matrix2(Vector2(1, 0), Vector2(0, 1))

    public static func *(left: Matrix2, right: Matrix2) -> Matrix2 {
        return Matrix2(left.x * right, left.y * right)
    }

    public static func *(left: Matrix2, right: Vector2) -> Vector2 {
        return Vector2(left.x * right, left.y * right)
    }
}

public struct Matrix3: Hashable {
    public let x, y, z: Vector3
}

public extension Matrix3 {
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
}

extension Matrix3: Group {
    public static let zero = Matrix3(Vector3.zero, Vector3.zero, Vector3.zero)
}

extension Matrix3: Composite3 {
    public init(_ x: Vector3, _ y: Vector3, _ z: Vector3) {
        self.x = x
        self.y = y
        self.z = z
    }

    public typealias ComponentType = Vector3
}

extension Matrix3: Matrix {
    public var transposed: Matrix3 {
        return Matrix3(Vector3(x.x, y.x, z.x), Vector3(x.y, y.y, z.y), Vector3(x.y, y.y, z.z))
    }

    public static let identity = Matrix3(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))

    public static func *(left: Matrix3, right: Matrix3) -> Matrix3 {
        return Matrix3(left.x * right, left.y * right, left.z * right)
    }

    public static func *(left: Matrix3, right: Vector3) -> Vector3 {
        return Vector3(left.x * right, left.y * right, left.z * right)
    }
}
