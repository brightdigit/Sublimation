# SublimationVapor

Using `Sublimation` as `LifecycleHandler` for `Vapor`.

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

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationVapor/LICENSE) file for more info.

