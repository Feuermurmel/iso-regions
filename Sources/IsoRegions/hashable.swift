
public protocol EasyHashable: Hashable {
    static var hashableProperties: [(Self) -> AnyHashable] { get }
}

public extension EasyHashable {
    var hashValue: Int {
        return Self.hashableProperties.reduce(
            5381,
            { $0 * 33 + $1(self).hashValue })
    }
    
    static func ==(left: Self, right: Self) -> Bool {
        return Self.hashableProperties.all(where: { $0(left) == $0(right) })
    }
    
    static func defineHashableProperties(_ properties: (Self) -> AnyHashable...) -> [(Self) -> AnyHashable] {
        return properties
    }
}
