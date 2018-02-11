
func hashItems() -> Int {
    return 5381
}

func hashItems(_ item1: AnyHashable) -> Int {
    return hashItems() * 33 + item1.hashValue
}

func hashItems(_ item1: AnyHashable, _ item2: AnyHashable) -> Int {
    return hashItems(item1) * 33 + item2.hashValue
}

func hashItems(_ item1: AnyHashable, _ item2: AnyHashable, _ item3: AnyHashable) -> Int {
    return hashItems(item1, item2) * 33 + item3.hashValue
}

func hashItems(_ item1: AnyHashable, _ item2: AnyHashable, _ item3: AnyHashable, _ item4: AnyHashable) -> Int {
    return hashItems(item1, item2, item3) * 33 + item4.hashValue
}
