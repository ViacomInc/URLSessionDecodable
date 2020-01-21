// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "URLSessionDecodable",
    products: [
        .library(
            name: "URLSessionDecodable",
            targets: ["URLSessionDecodable"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "URLSessionDecodable",
            dependencies: []),
        .testTarget(
            name: "URLSessionDecodableTests",
            dependencies: ["URLSessionDecodable"]),
    ]
)
