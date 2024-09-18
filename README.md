<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Sources/Sublimation/Documentation.docc/Resources/Sublimation.svg" height="200">
</p>
<h1 align="center"> Sublimation </h1>

Enable **automatic discovery of your local development server** on the fly

Turn your Server-Side Swift app from a _mysterious vapor_ to a **tangible solid server**

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/Sublimation/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/Sublimation)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/Sublimation)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/Sublimation/Sublimation.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/Sublimation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/Sublimation)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/Sublimation)](https://codecov.io/gh/brightdigit/Sublimation)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/Sublimation)](https://www.codefactor.io/repository/github/brightdigit/Sublimation)
[![codebeat badge](https://codebeat.co/badges/54695d4b-98c8-4f0f-855e-215500163094)](https://codebeat.co/projects/github-com-brightdigit-Sublimation-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/Sublimation)](https://codeclimate.com/github/brightdigit/Sublimation)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/Sublimation?label=debt)](https://codeclimate.com/github/brightdigit/Sublimation)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/Sublimation)](https://codeclimate.com/github/brightdigit/Sublimation)

# Table of Contents

* [Introduction](#introduction)
  * [Requirements](#requirements)
* [Package Ecosystem](#package-ecosystem)
* [Usage](#usage)
* [Documentation](#documentation)
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

# Introduction
   
When you are developing a Full Stack Swift application, you want to easily test and debug your application on both the device (iPhone, Apple Watch, iPad, etc...) as well as your development server. If you are using simulator then setting your host server to `localhost` this may work but often you need to test on an actual device. 

For the server and client **we need a way to communicate that information** without the client knowing where the server is initially.

```mermaid
flowchart TD
%% Nodes for devices with Font Awesome icons
    subgraph Devices
    iPhone("fa:fa-mobile-alt iPhone")
    Watch("fa:fa-square Apple Watch")
    iPad("fa:fa-tablet-alt iPad")
    VisionPro("fa:fa-vr-cardboard Vision Pro")
    end
    
%% Node for Sublimation service with Font Awesome package icon
    Sublimation("fa:fa-box Sublimation")

%% Node for API server with Font Awesome icon
    Server("fa:fa-server API Server")

%% Edge connections
    Devices <--> Sublimation
    Sublimation <--> Server
```

## Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

For **older operating systems or Swift versions**, check out [the main branch and 1.0.0 releases](https://github.com/brightdigit/Sublimation).

# Package Ecosystem

| Repository                                                 | Description                                        |
| ----------                                                 | -----------                                        |
| [**SublimationBonjour**](https://github.com/brightdigit/SublimationBonjour) | `Sublimatory` for using [Bonjour](https://developer.apple.com/bonjour/) for auto-discovery for development server.                      |
| [**SublimationNgrok**](https://github.com/brightdigit/SublimationNgrok) | `Sublimatory` for using [Ngrok](https://ngrok.com/) and [KVdb](https://kvdb.io) to create public urls and share them.   |
| [**SublimationService**](https://github.com/brightdigit/SublimationService) | Use **Sublimation** as a [Lifecycle Service](https://github.com/swift-server/swift-service-lifecycle).   |
| [**SublimationVapor**](https://github.com/brightdigit/SublimationVapor) |   Use **Sublimation** as a [Vapor Lifecycle Handler](https://docs.vapor.codes/advanced/services/#lifecycle).      |

```mermaid
graph TD
    A[Which Sublimation Packages to Use] --> B{Need to publicly share URL?}
    B -->|Yes| C[Use **SublimationNgrok**]
    B -->|No| D[Use **SublimationBonjour**]
    C --> E{Which server framework?}
    D --> E
    E -->|*Vapor*| F[Use **SublimationVapor**]
    E -->|*Hummingbird* or other *Lifecycle Service*| G[Use **SublimationService** ]
```

To use **Sublimation**, you'll need to choose:

* **Sublimatory**, that is the method by which you advertise the development server
  * [**Bonjour**](https://developer.apple.com/bonjour/) via [SublimationBonjour](https://github.com/brightdigit/SublimationBonjour)  
  * [**Ngrok**](https://ngrok.com/) via [SublimationNgrok](https://github.com/brightdigit/SublimationBonjour) _which is only needed if you need to advertise your address publicaly_ 
* How it connects to the server
  * [Lifecycle Handler for Vapor](https://docs.vapor.codes/advanced/services/#lifecycle) via [SublimationVapor](https://github.com/brightdigit/SublimationBonjour)
  * [Lifecycle Service](https://github.com/swift-server/swift-service-lifecycle) via [SublimationService](https://github.com/brightdigit/SublimationBonjour) _for server frameworks such as [Hummingbird](https://docs.hummingbird.codes/2.0/documentation/hummingbird/)_

# Usage

For instance if you were using **Bonjour** with **Hummingbird** and an iOS app your package may look something like this:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-alpha.1"),
    .package(url: "https://github.com/brightdigit/SublimationBonjour.git", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SublimationService.git", from: "1.0.0")
  ],
  targets: [

      .target(
          name: "YouriOSApp",
          dependencies: [
            .product(name: "SublimationBonjour", package: "SublimationBonjour"),
            ...
          ]),
      ...
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "SublimationBonjour", package: "SublimationBonjour"),
            .product(name: "SublimationService", package: "SublimationService"), 
            ...
          ]),
      ...
  ]
)
```

If you were to use **Vapor** and **Ngrok** instead, it'd look more like this:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
    .package(url: "https://github.com/brightdigit/SublimationNgrok.git", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SublimationVapor.git", from: "1.0.0")
  ],
  targets: [

      .target(
          name: "YouriOSApp",
          dependencies: [
            .product(name: "SublimationKVdb", package: "SublimationNgrok"),
            ...
          ]),
      ...
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "SublimationNgrok", package: "SublimationNgrok"),
            .product(name: "SublimationVapor", package: "SublimationVapor"), 
            ...
          ]),
      ...
  ]
)
```

* _[Why KVdb for the app?](https://github.com/brightdigit/SublimationNgrok#client-setup)_

Please check the respective package documentation from the [Package Ecosystem](#package-ecosystem) section.

# Documentation

To learn more, check out the full [documentation](https://swiftpackageindex.com/brightdigit/Sublimation/2.0.0-beta.1/documentation/sublimation).

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/Sublimation/LICENSE) file for more info.
