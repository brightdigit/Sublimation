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

## Client Installation

In your Xcode project, add the swift package for Sublimation at:

```
https://github.com/brightdigit/Sublimation.git
```

In your application target, you only need a reference to the `Sublimation` library. 

# Bonjour vs Ngrok

Unless you need public exposure for your development server, **your best bet is to use _Bonjour_ for letting your devices know about your server.** 

## Using Bonjour

In order to use Bonjour to notify your network devices of your server, you need to add Sublimation as part of [the lifecycle of your server application](https://docs.vapor.codes/advanced/services/#lifecycle). By default, Sublimation uses Bonjour and all the default parameters should be sufficient. Here's an example for Vapor:

```swift
#if os(macOS) && DEBUG
  app.lifecycle.use(
    Sublimation()
  )
#endif
```

Notice:
1. You'll only want to **run this in development.**
2. Sublimation **only works on macOS** and not Linux.

### How it works 

The `BonjourSublimatory` does 2 things:

1. Gets the address of the server host.
2. Start an [`NWListener`](https://developer.apple.com/documentation/network/nwlistener) to advertise those addresses.

Once your server is started, it should automatically advertise these on your local network. 

In your client application, you'll need to create a `BonjourDepositor`. The `BonjourDepositor` searches your network for you development server. You can call 'BonjourDepositor.urls' to get an [`AsyncStream`](https://developer.apple.com/documentation/swift/asyncstream) of urls. However in most cases `.first` should be sufficient:

```swift
let baseURL : URL
#if os(macOS) && DEBUG
  let depositor = BonjourDepositor()
  // hostURL = http://192.168.0.1
  guard let hostURL = await depositor.first() else {
    // handle when no url is returned
  }
  // hostURL = http://192.168.0.1/api/v1/
  baseURL = hostURL.appendPathComponent("/api/v1/")
#else
  // handle instances where the server is running 
  //  outside of your development environment (i.e. staging, production, etc...)
#endif
```

## Using Ngrok

[Ngrok](https://ngrok.com) is a fantastic service for setting up local development server for outside access. Let's say you need to share your local development server because you're testing on an actual device which can't access your machine via your local network. You can run `ngrok` to setup an https address which tunnels to your local development server:

```bash
> vapor run serve -p 1337
> ngrok http 1337
```
Now you'll get a message saying your vapor app is served through ngrok:

```
Forwarding https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io -> http://localhost:1337 
```

Sublimation can be used to automate this process and let your client devices automatically know.

### Using the Cloud for Meta-Server Access

With Sublimation and Ngrok you save the address (such as `https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io`) to a key-value storage and pull that address from your Apple device during development.

### Cloud Setup

If you haven't already setup an account with ngrok and install the command-line tool via homebrew. Next let's setup a key-value storage with kvdb.io which is currently supported. _If you have another service, please create an issue in the repo. Your feedback is helpful._ 

Sign up at [kvdb.io](https://kvdb.io) and get a bucket name you'll use. You'll be using that for your setup. Essentially there are three components you'll need:

* path to ngrok on your machine - if you installed via homebrew it's `/opt/homebrew/bin/ngrok` but you can find out using: `which ngrok` after installation
* your kvdb.io bucket name 
* your kvdb.io key - you just need to pick something unique for your server and client to use

Now let's setup your Vapor server application...

### On your server

`Sublimation`  makes it easy to setup `Ngrok` by passing in the path to ngrok and the information from KVdb. Simply add `Sublimation` to your server application. In the case of Vapor add it to your lifecycle:

```swift
let app = Application(env)
...
app.lifecycle.use(
  Sublimation(
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
