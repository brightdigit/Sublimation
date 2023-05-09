// swift-tools-version:5.7
// swiftlint:disable explicit_top_level_acl explicit_acl

import PackageDescription

let package = Package(
  name: "Prch",
  platforms: [.macOS(.v12), .iOS(.v14), .watchOS(.v7)],
  products: [
    .library(
      name: "Prch",
      targets: ["Prch"]
    ),
    .library(
      name: "PrchModel",
      targets: ["PrchModel"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
  ],
  targets: [
    .target(name: "Prch", dependencies: ["PrchModel"]),
    .target(name: "PrchModel", dependencies: []),
    .testTarget(name: "PrchTests", dependencies: ["Prch"])
  ]
)
