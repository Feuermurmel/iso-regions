// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "test-project",
    dependencies: [
        .package(url: "https://github.com/Feuermurmel/iso-regions.git", from: "0.0.1")],
    targets: [
        .target(name: "main", dependencies: ["IsoRegions"])])
