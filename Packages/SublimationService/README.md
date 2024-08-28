<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Sources/SublimationService/Documentation.docc/Resources/SublimationService.svg" height="200">
</p>
<h1 align="center">SublimationService</h1>

Using [Sublimation](https://github.com/brightdigit/Sublimation) as a [Lifecycle Service](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/2.6.1/documentation/servicelifecycle) for applications such as [Hummingbird](https://github.com/hummingbird-project/hummingbird).

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SublimationService/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SublimationService)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SublimationService)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SublimationService/SublimationService.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationService%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SublimationService)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationService%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SublimationService)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SublimationService)](https://codecov.io/gh/brightdigit/SublimationService)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SublimationService)](https://www.codefactor.io/repository/github/brightdigit/SublimationService)
[![codebeat badge](https://codebeat.co/badges/88cc9ee4-5180-4ce5-93c6-a2e23dd532c3)](https://codebeat.co/projects/github-com-brightdigit-SublimationService-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SublimationService)](https://codeclimate.com/github/brightdigit/SublimationService)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SublimationService?label=debt)](https://codeclimate.com/github/brightdigit/SublimationService)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SublimationService)](https://codeclimate.com/github/brightdigit/SublimationService)

# Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Documentation](#documentation)   
* [License](#license)

# Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

# Installation

To integrate **SublimationService** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SublimationService.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "SublimationService", package: "SublimationService"), ...
          ]),
      ...
  ]
)
```

# Usage

For instance if you are using this with [Hummingbird](https://github.com/hummingbird-project/hummingbird) and using [Bonjour](https://github.com/brightdigit/SublimationBonjour), you can just add it as a service:

```swift
let sublimation = Sublimation(
  bindingConfiguration: .init(
    hosts: hosts, 
    configuration: configuration.hosting
  )
)

var app = Application(
  router: router,
  server: .http1WebSocketUpgrade(webSocketRouter: wsRouter),
  configuration: .init(address: .init(setup: configuration.hosting))
)

app.addServices(sublimation)
```

## Documentation

To learn more, check out the full [documentation](https://swiftpackageindex.com/brightdigit/SublimationService/documentation).

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationService/LICENSE) file for more info.

