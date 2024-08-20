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
    .library(name: "SublimationCore", targets: ["SublimationCore"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
  ],
  targets: [  
    .target(
      name: "Sublimation",
      dependencies: [
        "SublimationCore",
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
    .testTarget(
      name: "SublimationTests",
      dependencies: ["Sublimation"]
    )
  ]
)

