<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Sources/SublimationVapor/Documentation.docc/Resources/SublimationVapor.svg" height="200">
</p>
<h1 align="center">SublimationVapor</h1>

Using `Sublimation` as `LifecycleHandler` for `Vapor`.

 [![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
 [![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
 ![GitHub](https://img.shields.io/github/license/brightdigit/SublimationVapor)
 ![GitHub issues](https://img.shields.io/github/issues/brightdigit/SublimationVapor)
 ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SublimationVapor/SublimationVapor.yml?label=actions&logo=github&?branch=main)

 [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationVapor%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SublimationVapor)
 [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationVapor%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SublimationVapor)


 <!--
 [![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SublimationVapor)](https://codecov.io/gh/brightdigit/SublimationVapor)
 -->
 [![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SublimationVapor)](https://www.codefactor.io/repository/github/brightdigit/SublimationVapor)
 [![codebeat badge](https://codebeat.co/badges/a0c6c5c9-4718-499d-9533-725572908e17)](https://codebeat.co/projects/github-com-brightdigit-SublimationVapor-main)
 [![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SublimationVapor)](https://codeclimate.com/github/brightdigit/SublimationVapor)
 [![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SublimationVapor?label=debt)](https://codeclimate.com/github/brightdigit/SublimationVapor)
 [![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SublimationVapor)](https://codeclimate.com/github/brightdigit/SublimationVapor)
 [![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

## Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

# Installation

Sublimation has two components: Server and Client. You can check out the SublimationDemoApp Xcode project for an example.

To integrate **Sublimation** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SublimationVapor.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "SublimationVapor", package: "SublimationVapor"), ...
          ]),
      ...
  ]
)
```

## Usage

For `Vapor`, you add it to the lifecycle of the app:

```swift
let sublimation = Sublimation(
  bindingConfiguration: .init(
    hosts: hosts, 
    configuration: configuration.hosting
  )
)

var app : Application

app.lifecycle.use(sublimation)
```

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationVapor/LICENSE) file for more info.
