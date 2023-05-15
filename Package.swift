// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "Sublimation",
  platforms: [.macOS(.v12), .iOS(.v14), .watchOS(.v7)],
  products: [
    .library(name: "Sublimation", targets: ["Sublimation"]),
    .library(name: "SublimationVapor", targets: ["SublimationVapor"]),
    .library(name: "Ngrokit", targets: ["Ngrokit"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.66.0"),
    .package(url: "https://github.com/brightdigit/Prch.git", from: "1.0.0-alpha.1"),
    .package(url: "https://github.com/brightdigit/PrchVapor.git", from: "1.0.0-alpha.1")
  ],
  targets: [
    .target(name: "Ngrokit", dependencies: ["Prch"]),
    .target(name: "Sublimation"),
    .target(name: "SublimationVapor",
            dependencies: [
              "Ngrokit", "PrchVapor", "Sublimation",
              .product(name: "Vapor", package: "vapor")
            ])
  ]
)
