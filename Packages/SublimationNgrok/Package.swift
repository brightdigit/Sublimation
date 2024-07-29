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
    .package(path: "../.."),
    .package(path: "../Ngrokit")
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
        .product(name: "Ngrokit", package: "Ngrokit")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SublimationKVdb",
      dependencies: ["SublimationTunnel"],
      swiftSettings: swiftSettings
    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
