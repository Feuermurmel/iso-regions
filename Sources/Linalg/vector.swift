import Foundation
import Util

// TODO: We should have a `public typealias ComponentType = Double` here, but swiftc crashes if we do.
public protocol Vector: Composite {
    associatedtype CompatibleMatrix: Matrix where CompatibleMatrix.ComponentType == Self

    static func *(left: Self, right: Self) -> Double

    static func outer(left: Self, right: Self) -> CompatibleMatrix
}

public extension Vector {
    var norm: Double {
        return sqrt(self * self)
    }

    var normalized: Self {
        return self / self.norm
    }
}

public struct Vector0: Hashable {
    public init() {
    }
}

extension Vector0: Field {
    public static let zero = Vector0()
}

extension Vector0: Composite {
    public var x: Double {
        return 0
    }

    // TODO: This becomes redundant once we can move it to protocol Vector.
    public typealias ComponentType = Double
}

extension Vector0: Composite0 {
}

extension Vector0: Vector {
    public typealias CompatibleMatrix = Matrix0

    public static func *(left: Vector0, right: Vector0) -> Double {
        return 0
    }

    public static func outer(left: Vector0, right: Vector0) -> Matrix0 {
        return Matrix0()
    }
}

public struct Vector1: Hashable {
    public let x: Double
}

extension Vector1: Field {
    public static let zero = Vector1(0)
}

extension Vector1: Composite {
    // TODO: This becomes redundant once we can move it to protocol Vector.
    public typealias ComponentType = Double
}

extension Vector1: Composite1 {
    public init(_ x: Double) {
        self.x = x
    }
}

extension Vector1: Vector {
    public typealias CompatibleMatrix = Matrix1

    public static func *(left: Vector1, right: Vector1) -> Double {
        return left.x * right.x
    }

    public static func outer(left: Vector1, right: Vector1) -> Matrix1 {
        return Matrix1(left.x * right)
    }
}

public struct Vector2: Hashable {
    public let x, y: Double
}

public extension Vector2 {
    public init(angle: Double, length: Double = 1) {
        self.init(cos(angle) * length, sin(angle) * length)
    }
}

extension Vector2: Field {
    public static let zero = Vector2(0, 0)
}

extension Vector2: Composite {
    // TODO: This becomes redundant once we can move it to protocol Vector.
    public typealias ComponentType = Double
}

extension Vector2: Composite2 {
    // See https://bugs.swift.org/browse/SR-3003
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

extension Vector2: Vector {
    public typealias CompatibleMatrix = Matrix2

    public static func *(left: Vector2, right: Vector2) -> Double {
        return left.x * right.x + left.y * right.y
    }

    public static func outer(left: Vector2, right: Vector2) -> Matrix2 {
        return Matrix2(left.x * right, left.y * right)
    }
}

public struct Vector3: Hashable {
    public let x, y, z: Double
}

extension Vector3: Field {
    public static let zero = Vector3(0, 0, 0)
}

extension Vector3: Composite {
    // TODO: This becomes redundant once we can move it to protocol Vector.
    public typealias ComponentType = Double
}

extension Vector3: Composite3 {
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector3: Vector {
    public typealias CompatibleMatrix = Matrix3

    public static func *(left: Vector3, right: Vector3) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }

    public static func outer(left: Vector3, right: Vector3) -> Matrix3 {
        return Matrix3(left.x * right, left.y * right, left.z * right)
    }
}
