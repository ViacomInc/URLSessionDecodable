// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "URLSessionDecodable",
    platforms: [
        .macOS(.v13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "URLSessionDecodable",
            targets: ["URLSessionDecodable"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "URLSessionDecodable",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "URLSessionDecodableTests",
            dependencies: ["URLSessionDecodable"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
