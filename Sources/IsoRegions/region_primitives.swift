import Foundation
import Linalg

public func void() -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        (.infinity, .zero)
    }
}

public func plane() -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        (coordinate.x, Vector2(1, 0))
    }
}

public func circle(radius: Double) -> IsoRegion2 {
    return IsoRegion2 { coordinate in
        return (coordinate.norm - radius, coordinate.normalized)
    }
}
