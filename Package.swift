// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "IsoRegions",
    products: [
        .library(name: "IsoRegions", targets: ["IsoRegions"]),
        .executable(name: "test", targets: ["Test"])],
    targets: [
        .target(name: "IsoRegions", dependencies: ["Internals"]),
        .target(name: "Internals"),
        .target(name: "Test", dependencies: ["IsoRegions"]),
        .testTarget(name: "UnitTests", dependencies: ["IsoRegions", "Internals"])])
