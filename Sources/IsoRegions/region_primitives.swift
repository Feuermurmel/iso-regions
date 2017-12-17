import Foundation

public func void() -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        IsoPoint2(value: Double.infinity, derivative: Vector2.zero)
    }
}

public func plane() -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        IsoPoint2(value: coordinate.x, derivative: Vector2(1, 0))
    }
}

public func circle(radius: Double) -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        return IsoPoint2(value: coordinate.norm - radius, derivative: coordinate.normalized)
    }
}
