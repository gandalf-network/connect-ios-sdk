// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GandalfConnect",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        .library(
            name: "GandalfConnect",
            targets: ["GandalfConnect"]),
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
            name: "GandalfConnect",
            dependencies: [
              .product(name: "GandalfConnectAPI", package: "GandalfConnectAPI"),
              .product(name: "Apollo", package: "apollo-ios"),
            ],
            path: "./Sources/GandalfConnect"
        ),
        .executableTarget(
            name: "Example",
            dependencies: ["GandalfConnect"],
            path: "./Sources/Example"
        ),
        .testTarget(
            name: "GandalfConnectTests",
            dependencies: ["GandalfConnect"]),
    ]
)
