# SublimationService

Using `Sublimation` as Lifecycle Service for application such as Hummingbird.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SublimationService)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SublimationService)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SublimationService/SublimationService.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationService%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SublimationService)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationService%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SublimationService)


<!--
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SublimationService)](https://codecov.io/gh/brightdigit/SublimationService)
-->
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SublimationService)](https://www.codefactor.io/repository/github/brightdigit/SublimationService)
[![codebeat badge](https://codebeat.co/badges/54695d4b-98c8-4f0f-855e-215500163094)](https://codebeat.co/projects/github-com-brightdigit-SublimationService-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SublimationService)](https://codeclimate.com/github/brightdigit/SublimationService)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SublimationService?label=debt)](https://codeclimate.com/github/brightdigit/SublimationService)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SublimationService)](https://codeclimate.com/github/brightdigit/SublimationService)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

# Table of Contents

* [Introduction](#introduction)
   * [Requirements](#requirements)
* [Installation](#installation)
   * [Server Installation](#server-installation)
   * [Client Installation](#client-installation)
* [Bonjour vs Ngrok](#bonjour-vs-ngrok)
   * [Using Bonjour](#using-bonjour)
   * [Using Ngrok](#using-ngrok)
* [License](#license)

# Introduction

For instance if you are using this with Hummingbird, you can just add it as a service:

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

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationService/LICENSE) file for more info.

