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
  name: "SublimationVapor",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
    .visionOS(.v1),
    .macCatalyst(.v17)
  ],
  products: [
    .library(name: "SublimationVapor", targets: ["SublimationVapor"])
  ],
  dependencies: [
    .package(url: "https://github.com/brightdigit/Sublimation", branch: "32-swift-service-lifecycle-ci"),
    .package(
      url: "https://github.com/vapor/vapor.git",
      from: "4.92.0"
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
      name: "SublimationVapor",
      dependencies: [
        .product(
          name: "OpenAPIAsyncHTTPClient",
          package: "swift-openapi-async-http-client"
        ),
        .product(
          name: "SublimationCore",
          package: "Sublimation"
        ),
        .product(
          name: "Sublimation",
          package: "Sublimation"
        ),
        .product(
          name: "Vapor",
          package: "vapor"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SublimationVaporTests",
      dependencies: ["SublimationVapor"]
    )
  ]
)

