// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SublimationDemoServer",
  platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10)],
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
