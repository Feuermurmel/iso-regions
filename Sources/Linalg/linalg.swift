import Foundation
import Util

public protocol Group: Hashable {
    static var zero: Self { get }

    static func +(left: Self, right: Self) -> Self
    static func *(left: Self, right: Double) -> Self
}

public extension Group {
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

extension Double: Group {
    public static let zero = 0.0
}

public protocol Composite: Group {
    /// The first component or row in any vector or matrix. Having access to this without knowing the exact type is sometimes useful.
    var x: ComponentType { get }

    associatedtype ComponentType: Group
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

    public var hashValue: Int {
        return hashItems(x)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x
    }
}

extension Double: Composite1 {
    public var x: Double {
        return self
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

    public var hashValue: Int {
        return hashItems(x, y)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
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

    public var hashValue: Int {
        return hashItems(x, y, z)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
