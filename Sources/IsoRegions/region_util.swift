import Foundation
import Linalg

public func shell(_ region: IsoRegion2, thickness: Double) -> IsoRegion2 {
    return zeroOffsetOperation(region) { point in
        let point2 = (-point.value - thickness, -point.derivative)

        return pointWithLargerValue(point, point2)
    }
}

public func bands(_ region: IsoRegion2, count: Int, stepSize: Double = 1) -> IsoRegion2 {
    if count > 0 {
        return region / bands(region >> stepSize, count: count - 1, stepSize: stepSize)
    } else {
        return void()
    }
}
