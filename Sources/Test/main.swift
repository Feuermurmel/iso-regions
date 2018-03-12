import Foundation
import IsoRegions

extension Double {
    var degrees: Double {
        return (self / 360).turns
    }

    var turns: Double {
        return self * Double.tau
    }
}

func main() {
    let c = circle(radius: 1)

    let regions = [
        c | c.move(x: 1.8),
        c | c.move(x: 1.8) %% 0.5,
        c | c.move(x: 1.8) %% chamfer(0.5)]

    let region2 = regions.enumerated().map({ $0.element.move(y: Double($0.offset) * 2.5) }).union()

    let region3 = bands(region2, count: 20, stepSize: 0.05)

//    let region3 = tube(radius: 5, plane(), plane().rotate(0.25.turns))

    let object = render(region: region3, resolution: 0.01839487)
    try! object.toSaveable(lineThicknessInUnits: 0.01, storePhysicalSize: false).save(toFile: "output/lala.svg")
}

main()
