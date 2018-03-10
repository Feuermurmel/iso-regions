// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "IsoRegions",
    products: [
        .library(name: "IsoRegions", targets: ["IsoRegions"]),
        .executable(name: "test", targets: ["Test"])],
    targets: [
        .target(name: "Util"),
        .target(name: "Linalg", dependencies: ["Util"]),
        .target(name: "IsoRegions", dependencies: ["Util", "Linalg"]),
        .target(name: "Test", dependencies: ["IsoRegions"]),
        .testTarget(name: "UnitTests", dependencies: ["Util", "IsoRegions", "Linalg"])])
