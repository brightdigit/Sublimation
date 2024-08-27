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
  SwiftSetting.enableUpcomingFeature("InternalImportsByDefault")

// SwiftSetting.unsafeFlags([
//   "-Xfrontend",
//   "-warn-long-function-bodies=100"
// ]),
// SwiftSetting.unsafeFlags([
//   "-Xfrontend",
//   "-warn-long-expression-type-checking=100"
// ])
]

let package = Package(
  name: "Ngrokit",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
    .macCatalyst(.v17)
  ],
  products: [
    .library(name: "Ngrokit", targets: ["Ngrokit"]),
    .library(name: "NgrokitMocks", targets: ["NgrokitMocks"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-openapi-runtime",
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
      name: "NgrokitMocks",
      dependencies: ["Ngrokit"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "NgrokitTests",
      dependencies: ["Ngrokit", "NgrokitMocks"]
    )
  ]
)

