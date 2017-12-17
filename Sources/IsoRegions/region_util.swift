import Foundation

public func shell(_ region: IsoRegion2, thickness: Double) -> IsoRegion2 {
    return zeroOffsetOperation(region) { point in
        return pointWithLargerValue(
            point,
            IsoPoint2(value: -point.value - thickness, derivative: -point.derivative))
    }
}

public func bands(_ region: IsoRegion2, count: Int, stepSize: Double = 1) -> IsoRegion2 {
    if count > 0 {
        return region / bands(region >> stepSize, count: count - 1, stepSize: stepSize)
    } else {
        return void()
    }
}
