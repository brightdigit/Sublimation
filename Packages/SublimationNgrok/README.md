<p align="center">
    <img alt="Sublimation" title="Sublimation" src="Sources/SublimationNgrok/Documentation.docc/Resources/SublimationNgrok.svg" height="200">
</p>
<h1 align="center">SublimationNgrok</h1>

Share your local development server easily with your Apple devices via [Sublimation](https://github.com/brightdigit/Sublimation) and [Ngrok](https://ngrok.com).

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SublimationNgrok/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SublimationNgrok)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SublimationNgrok)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SublimationNgrok/SublimationNgrok.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationNgrok%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SublimationNgrok)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSublimationNgrok%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SublimationNgrok)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SublimationNgrok)](https://codecov.io/gh/brightdigit/SublimationNgrok)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SublimationNgrok)](https://www.codefactor.io/repository/github/brightdigit/SublimationNgrok)
[![codebeat badge](https://codebeat.co/badges/30c1c6a6-c7f5-4c94-8e17-90d3fbd95475)](https://codebeat.co/projects/github-com-brightdigit-SublimationNgrok-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SublimationNgrok)](https://codeclimate.com/github/brightdigit/SublimationNgrok)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SublimationNgrok?label=debt)](https://codeclimate.com/github/brightdigit/SublimationNgrok)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SublimationNgrok)](https://codeclimate.com/github/brightdigit/SublimationNgrok)

# Table of Contents

* [Introduction](#introduction)
  * [Requirements](#requirements)
  * [Installation](#installation)
* [Usage](#usage)
    * [Cloud Setup](#cloud-setup)
    * [Server Setup](#server-setup)
    * [Client Setup](#client-setup)
* [Documentation](#documentation)    
* [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->


# Introduction

```mermaid
sequenceDiagram
    participant DevServer as Development Server
    participant Sub as Sublimation (Server)
    participant Ngrok as Ngrok (https://ngrok.com)
    participant KVdb as KVdb (https://kvdb.io)
    participant SubClient as Sublimation (Client)
    participant App as iOS/watchOS App
    
    DevServer->>Sub: Start development server
    Sub->>Ngrok: Request public URL
    Ngrok-->>Sub: Provide public URL<br/>(https://abc123.ngrok.io)
    Sub->>KVdb: Store URL with bucket and key<br/>(bucket: "fdjf9012k20cv", key: "dev-server",<br/>url: https://abc123.ngrok.io)
    App->>SubClient: Request server URL<br/>(bucket: "fdjf9012k20cv", key: "dev-server")
    SubClient->>KVdb: Request URL<br/>(bucket: "fdjf9012k20cv", key: "dev-server")
    KVdb-->>SubClient: Provide stored URL<br/>(https://abc123.ngrok.io)
    SubClient-->>App: Return server URL<br/>(https://abc123.ngrok.io)
    App->>Ngrok: Connect to development server<br/>(https://abc123.ngrok.io)
    Ngrok->>DevServer: Forward request to local server
```

Ngrok is a fantastic service for setting up local development server for outside access. Let's say you need to share your local development server because you're testing on an actual device which can't access your machine via your local network. You can run `ngrok` to setup an https address which tunnels to your local development server:

```bash
> vapor run serve -p 1337
> ngrok http 1337
```
Now you'll get a message saying your vapor app is served through ngrok:

```
Forwarding https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io -> http://localhost:1337 
```

With SublimationNgrok you save the address (such as `https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io`) to a key-value storage and pull that address from your Apple device during development.

## Requirements 

**Apple Platforms**

- Xcode 16.0 or later
- Swift 6.0 or later
- iOS 17 / watchOS 10.0 / tvOS 17 / macOS 14 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 6.0 or later

## Installation

Sublimation has two components: Server and Client. You can check out the SublimationDemoApp Xcode project for an example.

To integrate **Sublimation** into your app using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SublimationNgrok.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "YourServerApp",
          dependencies: [
            .product(name: "SublimationNgrok", package: "SublimationNgrok"), ...
          ]),
      ...
  ]
)
```

# Usage

### Cloud Setup

If you haven't already setup an account with ngrok and install the command-line tool via homebrew. Next let's setup a key-value storage with kvdb.io which is currently supported. _If you have another service, please create an issue in the repo. Your feedback is helpful._ 

Sign up at kvdb.io and get a bucket name you'll use. You'll be using that for your setup. Essentially there are three components you'll need:

* **ngrok executable path**
    - if you installed via homebrew it's `/opt/homebrew/bin/ngrok` but you can find out using: `which ngrok` after installation
* your kvdb.io **bucket name**
* your kvdb.io **key**
    - you just need to pick something unique for your server and client to use

Save these somewhere in your shared configuration for both your server and client to access, such as an `enum`:

```swift
public enum SublimationConfiguration {
  public static let bucketName = "fdjf9012k20cv"
  public static let key = "my-"
}
```

### Server Setup

When creating your `Sublimation` object you'll want to use the provided convenience initializers `TunnelSublimatory.init(ngrokPath:bucketName:key:application:isConnectionRefused:ngrokClient:)` to make it easier for **ngrok** integration with the `TunnelSublimatory`:

```swift
let tunnelSublimatory = TunnelSublimatory(
  ngrokPath: "/opt/homebrew/bin/ngrok", // path to ngrok executable
  bucketName: SublimationConfiguration.bucketName, // "fdjf9012k20cv"
  key: SublimationConfiguration.key, // "dev-server"
  application: { myVaporApplication }, // pass your Vapor.Application here
  isConnectionRefused: {$.isConnectionRefused}, // supplied by `SublimationVapor`
  transport: AsyncHTTPClientTransport() // ClientTransport for Vapor
)

let sublimation = Sublimation(sublimatory: tunnelSublimatory)
```

### Client Setup

For the client, you'll need to import the `SublimationKVdb` module and retrieve the url via:

```swift
import SublimationKVdb

let hostURL = try await KVdb.url(
  withKey: SublimationConfiguration.key, 
  atBucket: SublimationConfiguration.bucketName
) 
```

# Documentation

To learn more, check out the full [documentation](https://swiftpackageindex.com/brightdigit/Ngrokit/documentation).

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SublimationNgrok/LICENSE) file for more info.
