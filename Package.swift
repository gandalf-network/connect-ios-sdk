// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GandalfConnectIOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GandalfConnectIOS",
            targets: ["GandalfConnectIOS"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            path: "./GandalfConnectAPI"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GandalfConnectIOS",
            path: "./Sources"
        ),
        .testTarget(
            name: "GandalfConnectIOSTests",
            dependencies: ["GandalfConnectIOS"]),
    ]
)
