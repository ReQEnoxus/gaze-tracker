// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GazeTracker",
    platforms: [.iOS("13.4")],
    products: [
        .library(
            name: "GazeTracker",
            targets: ["GazeTracker"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/devicekit/DeviceKit.git",
            .upToNextMajor(from: "4.0.0")
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "GazeTracker",
            dependencies: [
                .product(name: "DeviceKit", package: "DeviceKit"),
                .product(name: "Collections", package: "swift-collections")
            ],
            exclude: [
                "../../Example"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
