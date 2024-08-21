// swift-tools-version: 6.0

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
  name: "SublimationNgrok",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
    .macCatalyst(.v17)
  ],
  products: [
    .library(name: "SublimationNgrok", targets: ["SublimationNgrok"])
  ],
  dependencies: [
    .package(url: "https://github.com/brightdigit/Sublimation", branch: "32-swift-service-lifecycle-ci"),
    .package(url: "https://github.com/brightdigit/Ngrokit", branch: "v1.0.0")
  ],
  targets: [
    .target(
      name: "SublimationTunnel",
      dependencies: [
        .product(name: "SublimationCore", package: "Sublimation")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationNgrok",
      dependencies: [
        "SublimationTunnel",
        "SublimationKVdb",
        .product(name: "Ngrokit", package: "Ngrokit")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationKVdb",
      dependencies: ["SublimationTunnel"],
      swiftSettings: swiftSettings
    ),
    .target(
        name: "SublimationMocks",
        dependencies: ["Sublimation"],
        swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SublimationKVdbTests",
      dependencies: ["SublimationKVdb", "SublimationMocks"]
    ),
    .testTarget(
      name: "SublimationTunnelTests",
      dependencies: ["SublimationTunnel", "SublimationMocks"]
    ),
    .testTarget(
      name: "SublimationNgrokTests",
      dependencies: ["SublimationNgrok", "SublimationMocks", .product(name: "NgrokitMocks", package: "Ngrokit")]
    ),
  ]
)

