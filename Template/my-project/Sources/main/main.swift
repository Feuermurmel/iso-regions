import IsoRegions

let object = render(region: circle(radius: 1), resolution: 0.1)
try! object
    .toSaveable(lineThicknessInUnits: 0.01, storePhysicalSize: false)
    .save(toFile: "output/lala.svg")
