import Foundation
import Util

public protocol Component: Hashable {
    static var zero: Self { get }

    static func +(left: Self, right: Self) -> Self
    static func *(left: Self, right: Double) -> Self
}

public extension Component {
    static prefix func -(value: Self) -> Self {
        return -1.0 * value
    }

    static func -(left: Self, right: Self) -> Self {
        return left + (-right)
    }

    static func *(left: Double, right: Self) -> Self {
        return right * left
    }
}

extension Double: Component {
    public static let zero = 0.0
}

public protocol Composite: Component {
    associatedtype ComponentType: Component
}

public protocol Vector: Composite {
    static func *(left: Self, right: Self) -> Double
}

public extension Vector {
    var norm: Double {
        return sqrt(self * self)
    }

    public var normalized: Self {
        return self / self.norm
    }

    static func /(left: Self, right: Double) -> Self {
        return left * (1 / right)
    }
}

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

public protocol Composite2: Composite {
    var x: ComponentType { get }
    var y: ComponentType { get }

    init(_ x: ComponentType, _ y: ComponentType)
}

public extension Composite2 {
    public static func +(left: Self, right: Self) -> Self {
        return Self(left.x + right.x, left.y + right.y)
    }

    public static func *(left: Self, right: Double) -> Self {
        return Self(left.x * right, left.y * right)
    }
}

public struct Vector2: Vector, Composite2 {
    public let x, y: Double

    // See https://bugs.swift.org/browse/SR-3003
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    public init(angle: Double, length: Double = 1) {
        self.init(cos(angle) * length, sin(angle) * length)
    }

    public var hashValue: Int {
        return hashItems(x, y)
    }

    public static func ==(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public typealias ComponentType = Double

    public static let zero = Vector2(0, 0)

    public static func *(left: Vector2, right: Vector2) -> Double {
        return left.x * right.x + left.y * right.y
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

    public var hashValue: Int {
        return hashItems(x, y)
    }

    public static func ==(lhs: Matrix2, rhs: Matrix2) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
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

public protocol Composite3: Composite {
    var x: ComponentType { get }
    var y: ComponentType { get }
    var z: ComponentType { get }

    init(_ x: ComponentType, _ y: ComponentType, _ z: ComponentType)
}

public extension Composite3 {
    public static func +(left: Self, right: Self) -> Self {
        return Self(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    public static func *(left: Self, right: Double) -> Self {
        return Self(left.x * right, left.y * right, left.z * right)
    }
}

public struct Vector3: Vector, Composite3 {
    public let x, y, z: Double

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var hashValue: Int {
        return hashItems(x, y, z)
    }

    public static func ==(lhs: Vector3, rhs: Vector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    public typealias ComponentType = Double

    public static let zero = Vector3(0, 0, 0)

    public static func *(left: Vector3, right: Vector3) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
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

    public var hashValue: Int {
        return hashItems(x, y, z)
    }

    public static func ==(lhs: Matrix3, rhs: Matrix3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
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
