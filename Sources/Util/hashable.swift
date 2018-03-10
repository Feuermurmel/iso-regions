
public func hashItems() -> Int {
    return 5381
}

public func hashItems(_ item1: AnyHashable) -> Int {
    return hashItems() * 33 + item1.hashValue
}

public func hashItems(_ item1: AnyHashable, _ item2: AnyHashable) -> Int {
    return hashItems(item1) * 33 + item2.hashValue
}

public func hashItems(_ item1: AnyHashable, _ item2: AnyHashable, _ item3: AnyHashable) -> Int {
    return hashItems(item1, item2) * 33 + item3.hashValue
}

public func hashItems(_ item1: AnyHashable, _ item2: AnyHashable, _ item3: AnyHashable, _ item4: AnyHashable) -> Int {
    return hashItems(item1, item2, item3) * 33 + item4.hashValue
}
