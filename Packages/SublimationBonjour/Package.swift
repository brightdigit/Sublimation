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
  name: "SublimationBonjour",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
    .macCatalyst(.v17)
  ],
  products: [
    .library(name: "SublimationBonjour", targets: ["SublimationBonjour"])
  ],
  dependencies: [
    .package(path: "../.."),
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "SublimationBonjour",
      dependencies: [
        .product(name: "Sublimation", package: "Sublimation"),
        .product(name: "SublimationCore", package: "Sublimation"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf")
      ],
      swiftSettings: swiftSettings
    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
