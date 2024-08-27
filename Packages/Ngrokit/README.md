# Ngrokit

Swift API for Ngrok Agent API.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/Ngrokit)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/Ngrokit)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/Ngrokit/Ngrokit.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FNgrokit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/Ngrokit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FNgrokit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/Ngrokit)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/Ngrokit)](https://codecov.io/gh/brightdigit/Ngrokit)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/Ngrokit)](https://www.codefactor.io/repository/github/brightdigit/Ngrokit)
[![codebeat badge](https://codebeat.co/badges/c86641f5-fe51-4faa-ad5c-584740e9766b)](https://codebeat.co/projects/github-com-brightdigit-Ngrokit-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/Ngrokit)](https://codeclimate.com/github/brightdigit/Ngrokit)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/Ngrokit?label=debt)](https://codeclimate.com/github/brightdigit/Ngrokit)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/Ngrokit)](https://codeclimate.com/github/brightdigit/Ngrokit)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

# Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
    * [Connecting to the Local REST API](#connecting-to-the-local-rest-api)
    * [Starting the CLI Process](#starting-the-cli-process)
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

# Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

# Installation

To integrate **Ngrokit** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/Ngrokit.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "Ngrokit", package: "Ngrokit"), ...
          ]),
      ...
  ]
)
```

# Usage

Ngrokit is an easy to use Swift library for call the local Ngrok API as well as running the `ngrok` command. 

### Connecting to the Local REST API

Using the ``NgrokClient`` to connect to your local development server:

```swift
let client = NgrokClient(transport: URLSession.shared)
```

For using different transports see the client list at the [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator?tab=readme-ov-file#package-ecosystem). 

### Starting the CLI Process

Start the CLI process by using ``NgrokProcessCLIAPI``:

```swift
let cliAPI = NgrokProcessCLIAPI(ngrokPath: "/usr/local/bin/ngrok")
let process = api.process(forHTTPPort: 100)
process.run { let error in
  print(error)
}
```
# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/Ngrokit/LICENSE) file for more info.
