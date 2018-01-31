// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MyProject",
    dependencies: [
        .package(url: "https://github.com/Feuermurmel/iso-regions.git", from: "0.0.1")],
    targets: [
        .target(name: "Main", dependencies: ["IsoRegions"])])
