import Foundation
import Util

public protocol Field: Hashable {
    static var zero: Self { get }

    static func +(left: Self, right: Self) -> Self
    static func *(left: Self, right: Double) -> Self
}

public extension Field {
    static prefix func -(value: Self) -> Self {
        return -1.0 * value
    }

    static func -(left: Self, right: Self) -> Self {
        return left + (-right)
    }

    static func *(left: Double, right: Self) -> Self {
        return right * left
    }

    static func /(left: Self, right: Double) -> Self {
        return left * (1 / right)
    }
}

extension Double: Field {
    public static let zero = 0.0
}

public protocol Composite: Field {
    /// The first component or row in any vector or matrix. Having access to this without knowing the exact type is sometimes useful.
    var x: ComponentType { get }

    associatedtype ComponentType: Field
}

public protocol Composite0: Composite {
    init()
}

public extension Composite0 {
    public static func +(left: Self, right: Self) -> Self {
        return Self()
    }

    public static func *(left: Self, right: Double) -> Self {
        return Self()
    }
}

public protocol Composite1: Composite {
    init(_ x: ComponentType)
}

public extension Composite1 {
    public static func +(left: Self, right: Self) -> Self {
        return Self(left.x + right.x)
    }

    public static func *(left: Self, right: Double) -> Self {
        return Self(left.x * right)
    }
}

public protocol Composite2: Composite {
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

public protocol Composite3: Composite {
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
