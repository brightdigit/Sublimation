// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "SublimationDemoServer",
  platforms: [.macOS(.v12), .iOS(.v14), .watchOS(.v7)],
  products: [
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
