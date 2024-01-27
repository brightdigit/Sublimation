// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "Sublimation",
  platforms: [.macOS(.v14), .iOS(.v17), .watchOS(.v10)],
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
    .package(url: "https://github.com/brightdigit/PrchVapor.git", from: "1.0.0-alpha.1"),
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
    .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0")
  ],
  targets: [
    .target(name: "NgrokOpenAPIClient", dependencies: [.product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")]),
    .target(name: "Ngrokit", dependencies: ["Prch", "NgrokOpenAPIClient",
                                            .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")]),
    .testTarget(name: "NgrokitTests", dependencies: ["Ngrokit", .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")]),
    .target(name: "Sublimation"),
    .target(name: "SublimationVapor",
            dependencies: [
              .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
              "Ngrokit", "PrchVapor", "Sublimation",
              .product(name: "Vapor", package: "vapor")
            ])
  ]
)
