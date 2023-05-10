// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SublimationDemoServer",
  platforms: [.macOS(.v12), .iOS(.v14), .watchOS(.v7)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .executable(
      name: "SublimationDemoServer",
      targets: ["SublimationDemoServer"]
    ),
    .library(
      name: "SublimationDemoConfiguration",
      targets: ["SublimationDemoConfiguration"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.66.0"),
    .package(name: "Sublimation", path: "../..")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .executableTarget(
      name: "SublimationDemoServer",
      dependencies: [
        .product(name: "SublimationVapor", package: "Sublimation"),
        .product(name: "Vapor", package: "vapor"),
        "SublimationDemoConfiguration"
      ]
    ),
    .target(name: "SublimationDemoConfiguration")
  ]
)
