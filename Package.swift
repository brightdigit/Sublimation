// swift-tools-version: 5.9
// swiftlint:disable explicit_acl explicit_top_level_acl
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("BareSlashRegexLiterals"),
  .enableUpcomingFeature("ConciseMagicFile"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("ForwardTrailingClosures"),
  .enableUpcomingFeature("ImplicitOpenExistentials"),
  .enableUpcomingFeature("StrictConcurrency"),
  .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
  name: "Sublimation",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
    .macCatalyst(.v17)
  ],
  products: [
    .library(name: "Sublimation", targets: ["Sublimation"]),
    .library(name: "SublimationVapor", targets: ["SublimationVapor"]),
    .library(name: "Ngrokit", targets: ["Ngrokit"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/vapor/vapor.git",
      from: "4.92.0"
    ),
    .package(
      url: "https://github.com/apple/swift-openapi-generator",
      from: "1.0.0"
    ),
    .package(
      url: "https://github.com/apple/swift-openapi-runtime",
      from: "1.0.0"
    ),
    .package(
      url: "https://github.com/swift-server/swift-openapi-async-http-client",
      from: "1.0.0"
    )
  ],
  targets: [
    .target(
      name: "NgrokOpenAPIClient",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
      ]
    ),
    .target(
      name: "Ngrokit",
      dependencies: [
        "NgrokOpenAPIClient",
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "Sublimation",
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationVapor",
      dependencies: [
        .product(
          name: "OpenAPIAsyncHTTPClient",
          package: "swift-openapi-async-http-client"
        ),
        "Ngrokit",
        "Sublimation",
        .product(
          name: "Vapor",
          package: "vapor"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "NgrokitMocks",
      dependencies: ["Ngrokit"]
    ),
    .testTarget(
      name: "NgrokitTests",
      dependencies: ["Ngrokit", "NgrokitMocks"],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationMocks",
      dependencies: ["Sublimation"]
    ),
    .testTarget(
      name: "SublimationTests",
      dependencies: ["Sublimation", "SublimationMocks"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SublimationVaporTests",
      dependencies: ["SublimationVapor",
                     "NgrokitMocks"],
      swiftSettings: swiftSettings
    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
