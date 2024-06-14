// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "GandalfConnectAPI",
  platforms: [
    .iOS(.v15),
    .macOS(.v10_14),
  ],
  products: [
    .library(name: "GandalfConnectAPI", targets: ["GandalfConnectAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "GandalfConnectAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
  ]
)
