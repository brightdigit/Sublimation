// swift-tools-version: 6.0
// swiftlint:disable explicit_acl explicit_top_level_acl
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  SwiftSetting.enableExperimentalFeature("AccessLevelOnImport"),
  SwiftSetting.enableExperimentalFeature("BitwiseCopyable"),
  SwiftSetting.enableExperimentalFeature("GlobalActorIsolatedTypesUsability"),
  SwiftSetting.enableExperimentalFeature("IsolatedAny"),
  SwiftSetting.enableExperimentalFeature("MoveOnlyPartialConsumption"),
  SwiftSetting.enableExperimentalFeature("NestedProtocols"),
  SwiftSetting.enableExperimentalFeature("NoncopyableGenerics"),
  SwiftSetting.enableExperimentalFeature("RegionBasedIsolation"),
  SwiftSetting.enableExperimentalFeature("TransferringArgsAndResults"),
  SwiftSetting.enableExperimentalFeature("VariadicGenerics"),

  SwiftSetting.enableUpcomingFeature("FullTypedThrows"),
  SwiftSetting.enableUpcomingFeature("InternalImportsByDefault"),

  SwiftSetting.unsafeFlags([
    "-Xfrontend",
    "-warn-long-function-bodies=100"
  ]),
  SwiftSetting.unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=100"
  ])
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
    .library(name: "SublimationCore", targets: ["SublimationCore"]),
    .library(name: "SublimationTunnel", targets: ["SublimationTunnel"]),
    .library(name: "SublimationKVdb", targets: ["SublimationKVdb"])
    // .library(name: "SublimationVapor", targets: ["SublimationVapor"]),
    // .library(name: "Ngrokit", targets: ["Ngrokit"])
  ],
  dependencies: [
    //    .package(
//      url: "https://github.com/vapor/vapor.git",
//      from: "4.92.0"
//    ),
//    .package(
//      url: "https://github.com/apple/swift-openapi-generator",
//      from: "1.0.0"
//    ),
//    .package(
//      url: "https://github.com/apple/swift-openapi-runtime",
//      from: "1.0.0"
//    ),
//    .package(
//      url: "https://github.com/swift-server/swift-openapi-async-http-client",
//      from: "1.0.0"
//    ),
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
  ],
  targets: [
    //    .target(
//      name: "NgrokOpenAPIClient",
//      dependencies: [
//        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
//      ]
//    ),
//    .target(
//      name: "Ngrokit",
//      dependencies: [
//        "NgrokOpenAPIClient",
//        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
//      ],
//      swiftSettings: swiftSettings
//    ),
    .target(
      name: "Sublimation",
      dependencies: [
        "SublimationCore",
        "SublimationBonjour",
        // "SublimationNgrok",
        .product(name: "Logging", package: "swift-log")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationCore",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationTunnel",
      dependencies: ["SublimationCore"],
      swiftSettings: swiftSettings
    ),
//    .target(
//      name: "SublimationNgrok",
//      dependencies: ["SublimationTunnel", "Ngrokit"],
//      swiftSettings: swiftSettings
//    ),
    .target(
      name: "SublimationKVdb",
      dependencies: ["SublimationTunnel"],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationBonjour",
      dependencies: [
        "SublimationCore",

        .product(name: "SwiftProtobuf", package: "swift-protobuf")
      ],
      swiftSettings: swiftSettings
    )
//    .target(
//      name: "SublimationVapor",
//      dependencies: [
//        .product(
//          name: "OpenAPIAsyncHTTPClient",
//          package: "swift-openapi-async-http-client"
//        ),
//        "Ngrokit",
//        "Sublimation",
//        "SublimationKVdb",
//        .product(
//          name: "Vapor",
//          package: "vapor"
//        )
//      ],
//      swiftSettings: swiftSettings
//    ),
//    .target(
//      name: "NgrokitMocks",
//      dependencies: ["Ngrokit"],
//      swiftSettings: swiftSettings
//    ),
//    .testTarget(
//      name: "NgrokitTests",
//      dependencies: ["Ngrokit", "NgrokitMocks"],
//      swiftSettings: swiftSettings
//    ),
//    .target(
//      name: "SublimationMocks",
//      dependencies: ["Sublimation"],
//      swiftSettings: swiftSettings
//    ),
//    .testTarget(
//      name: "SublimationBonjourTests",
//      dependencies: ["SublimationMocks", "SublimationBonjour"],
//      swiftSettings: swiftSettings
//    ),
//    .testTarget(
//      name: "SublimationTunnelTests",
//      dependencies: ["SublimationTunnel", "SublimationMocks"],
//      swiftSettings: swiftSettings
//    ),
//    .testTarget(
//      name: "SublimationKVdbTests",
//      dependencies: ["SublimationMocks", "SublimationKVdb"],
//      swiftSettings: swiftSettings
//    ),
//    .testTarget(
//      name: "SublimationVaporTests",
//      dependencies: [
//        "SublimationVapor",
//        "NgrokitMocks"
//      ],
//      swiftSettings: swiftSettings
//    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
