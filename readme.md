# IsoRegions

**Package.swift:**

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "test-project",
    dependencies: [
        .package(url: "https://github.com/Feuermurmel/iso-regions.git", from: "0.0.1")],
    targets: [
        .target(name: "main", dependencies: ["IsoRegions"])])
```

**Sources/main/main.swift:**

```swift
import IsoRegions

let object = render(region: circle(radius: 1), resolution: 0.1)
try! object
    .toSaveable(lineThicknessInUnits: 0.01, storePhysicalSize: false)
    .save(toFile: "output/lala.svg")
```

**.gitignore:**

```sh
# SwiftPM-specific stuff
/.build
/Packages
/*.xcodeproj

# Default output directory for rendered files
/output
```
