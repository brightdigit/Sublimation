// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimuServer",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "SimuServer",
            targets: ["SimuServer"]),
        .library(name: "Sublimation", targets: ["Sublimation"]),
        .library(name: "Ngrokit", targets: ["Ngrokit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.66.0"),
        .package(url: "https://github.com/brightdigit/Prch.git", from: "0.2.1"),
        .package(url: "https://github.com/brightdigit/PrchVapor.git", from: "0.2.0-beta.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
      .executableTarget(
            name: "SimuServer",
            dependencies: [
              "Sublimation",
              .product(name: "Vapor", package: "vapor")
            ]),
      .target(name: "Ngrokit", dependencies: ["Prch"]),
      .target(name: "Sublimation",
              dependencies: [
                "Ngrokit","PrchVapor",
                .product(name: "Vapor", package: "vapor")
              ]),
        .testTarget(
            name: "SimuServerTests",
            dependencies: ["SimuServer"]),
    ]
)
