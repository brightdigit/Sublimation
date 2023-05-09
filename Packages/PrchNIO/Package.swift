// swift-tools-version:5.7
// swiftlint:disable explicit_top_level_acl line_length
import PackageDescription

let package = Package(
  name: "PrchNIO",
  platforms: [.macOS(.v12), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
  products: [
    .library(name: "PrchNIO", targets: ["PrchNIO"])
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.17.0"),
    .package(url: "https://github.com/brightdigit/Prch", branch: "floxbx")
  ],
  targets: [
    .target(name: "PrchNIO", dependencies: ["Prch", .product(name: "AsyncHTTPClient", package: "async-http-client")]),
    .testTarget(name: "PrchNIOTests", dependencies: ["PrchNIO"])
  ]
)
