import Foundation
import Util

public protocol Vector: Composite {
    static func *(left: Self, right: Self) -> Double
}

public extension Vector {
    var norm: Double {
        return sqrt(self * self)
    }

    var normalized: Self {
        return self / self.norm
    }
}

public struct Vector2 {
    public let x, y: Double
}

public extension Vector2 {
    public init(angle: Double, length: Double = 1) {
        self.init(cos(angle) * length, sin(angle) * length)
    }
}

extension Vector2: Group {
    public static let zero = Vector2(0, 0)
}

extension Vector2: Composite2 {
    public typealias ComponentType = Double

    // See https://bugs.swift.org/browse/SR-3003
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

extension Vector2: Vector {
    public static func *(left: Vector2, right: Vector2) -> Double {
        return left.x * right.x + left.y * right.y
    }
}

public struct Vector3 {
    public let x, y, z: Double
}

extension Vector3: Group {
    public static let zero = Vector3(0, 0, 0)
}

extension Vector3: Composite3 {
    public typealias ComponentType = Double

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector3: Vector {
    public static func *(left: Vector3, right: Vector3) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
}
