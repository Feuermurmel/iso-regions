import Foundation
import Linalg

public func void<R: IsoRegionProtocol>() -> R {
    return R { coordinate in
        return (.infinity, .zero)
    }
}

// TODO: `where R.CoordinateType.ComponentType == Double` becomes redundant once we can move this constraint to protocol Vector.
public func plane<R: IsoRegionProtocol>() -> R where R.CoordinateType.ComponentType == Double {
    return R { coordinate in
        (coordinate.x, R.CoordinateType.CompatibleMatrix.identity.x)
    }
}

public func circle<R: IsoRegionProtocol>(radius: Double) -> R {
    return R { coordinate in
        return (coordinate.norm - radius, coordinate.normalized)
    }
}
