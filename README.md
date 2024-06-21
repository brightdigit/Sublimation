<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Assets/logo.svg" height="200">
</p>
<h1 align="center"> Sublimation </h1>

Share your local development server easily with your Apple devices.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/Sublimation)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/Sublimation)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/Sublimation/Sublimation.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/Sublimation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/Sublimation)


<!--
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/Sublimation)](https://codecov.io/gh/brightdigit/Sublimation)
-->
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/Sublimation)](https://www.codefactor.io/repository/github/brightdigit/Sublimation)
[![codebeat badge](https://codebeat.co/badges/54695d4b-98c8-4f0f-855e-215500163094)](https://codebeat.co/projects/github-com-brightdigit-Sublimation-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/Sublimation)](https://codeclimate.com/github/brightdigit/Sublimation)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/Sublimation?label=debt)](https://codeclimate.com/github/brightdigit/Sublimation)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/Sublimation)](https://codeclimate.com/github/brightdigit/Sublimation)
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

When you are developing a full stack Swift application, you want to easily test and debug your application on both the device (iPhone, Apple Watch, iPad, etc...) as well as your development server. If you are using simulator then setting your host server to `localhost` will work but often we need to test on an actual device. You can either be an IT expert on your local network's DNS or you can use Sublimation to easily connect your local server to your device.

## Requirements 

**Apple Platforms**

- Xcode 15.0 or later
- Swift 5.9 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 5.9 or later

# Installation

Sublimation has two components: Server and Client. You can check out the SublimationDemoApp Xcode project for an example.

## Server Installation

To integrate **Sublimation** into your Vapor app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/Sublimation.git", from: "2.0.0-alpha.3")
  ],
  targets: [
      .target(
          name: "YourVaporServerApp",
          dependencies: [
            .product(name: "SublimationVapor", package: "Sublimation"), ...
          ]),
      ...
  ]
)
```

`SublimationVapor` is the product which gives us the `TunnelSublimationLifecycleHandler` we'll use to integrate `Sublimation` with your Vapor app. Simply add `TunnelSublimationLifecycleHandler` to your application:

```swift
let app = Application(env)
...
app.lifecycle.use(
  TunnelSublimationLifecycleHandler(
    ngrokPath: "/opt/homebrew/bin/ngrok",
    bucketName: "bucket-name",
    key: "application key name"
  )
)
```

This will run `ngrok` and setup the forwarding address. Once it receives the address it saves it your kvdb bucket with key setup here.

Remember the ngrok path is the path from your development machine while the bucket name is from kvdb.io. However, the key can be anything you want as long as it's consistent and used by your client. Speaking of your client, let's talk about setting this up in your iOS app.

### On your device

Now to pull the url saved by your service, all you have to call is:

```swift
import Sublimation

let baseURL = try await KVdb.url(withKey: key, atBucket: bucketName)
```

At the point, you'll have the base url of your Vapor application and can begin using it in your application!
# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/Sublimation/LICENSE) file for more info.

# References

* [How to create and advertise a Bonj…](https://forums.developer.apple.com/forums/thread/740932)
* [Get IP & Port from NWBrowser](https://forums.developer.apple.com/forums/thread/122638)
* [NSNetService](https://developer.apple.com/documentation/foundation/nsnetservice)
* [Deprecation of NSNetService and al…](https://forums.developer.apple.com/forums/thread/682744)
* [DNSServiceResolve(_:_:_:_:_:_:_:_:)](https://developer.apple.com/documentation/dnssd/1804744-dnsserviceresolve)
* [hostName](https://developer.apple.com/documentation/foundation/nsnetservice/1413300-hostname)
* [endpoint](https://developer.apple.com/documentation/network/nwbrowser/result/3200384-endpoint)
