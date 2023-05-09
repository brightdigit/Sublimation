// swift-tools-version:5.7
// swiftlint:disable explicit_top_level_acl line_length
import PackageDescription

let package = Package(
  name: "PrchVapor",
  platforms: [.macOS(.v12), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [
    .library(name: "PrchVapor", targets: ["PrchVapor"])
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
    .package(url: "https://github.com/brightdigit/PrchNIO.git", branch: "prch2")
  ],
  targets: [
    .target(name: "PrchVapor", dependencies: ["PrchNIO", .product(name: "Vapor", package: "vapor")])
  ]
)
