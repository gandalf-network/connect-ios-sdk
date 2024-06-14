// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GandalfConnectIOS",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        .library(
            name: "GandalfConnectIOS",
            targets: ["GandalfConnectIOS"]),
        .executable(
            name: "Example",
            targets: ["Example"])
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "1.12.2")),
        .package(path: "./GandalfConnectAPI"),
    ],
    targets: [
        .target(
            name: "GandalfConnectIOS",
            dependencies: [
              .product(name: "GandalfConnectAPI", package: "GandalfConnectAPI"),
              .product(name: "Apollo", package: "apollo-ios"),
            ],
            path: "./Sources/GandalfConnectIOS"
        ),
        .executableTarget(
            name: "Example",
            dependencies: ["GandalfConnectIOS"],
            path: "./Sources/Example"
        ),
        .testTarget(
            name: "GandalfConnectIOSTests",
            dependencies: ["GandalfConnectIOS"]),
    ]
)
