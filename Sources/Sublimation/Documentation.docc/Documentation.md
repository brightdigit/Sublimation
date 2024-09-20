# ``Sublimation``

Enable automatic discovery of your local development server on the fly by turning your server-side swift app from a mysterious vapor to a tangible solid server to connect to.

## Overview

![Sublimation Logo](Sublimation.svg)

When you are developing a full stack Swift application, you want to easily test and debug your application on both the device (iPhone, Apple Watch, iPad, etc...) as well as your development server. If you are using simulator then setting your host server to `localhost` will work but often we need to test on an actual device. 

For the server and client we need a way to communicate that information without the client knowing where the server is initially.

![Diagram on Sublimation Communication](Sublimation-Diagram.svg)

There's two ways to do this - have a consistent location for fetching the address or a way to discover the service on the network.

### Package Ecosystem

| Repository                                                 | Description                                        |
| ----------                                                 | -----------                                        |
| [**SublimationBonjour**](https://github.com/brightdigit/SublimationBonjour) | `Sublimatory` for using [Bonjour](https://developer.apple.com/bonjour/) for auto-discovery for development server.                      |
| [**SublimationNgrok**](https://github.com/brightdigit/SublimationNgrok) | `Sublimatory` for using [Ngrok](https://ngrok.com/) and [KVdb](https://kvdb.io) to create public urls and share them.   |
| [**SublimationService**](https://github.com/brightdigit/SublimationService) | Use **Sublimation** as a [Lifecycle Service](https://github.com/swift-server/swift-service-lifecycle).   |
| [**SublimationVapor**](https://github.com/brightdigit/SublimationVapor) |   Use **Sublimation** as a [Vapor Lifecycle Handler](https://docs.vapor.codes/advanced/services/#lifecycle).      |

![Choosing Sublimation Packages](Sublimation-Choose.svg)

To use **Sublimation**, you'll need to choose:

* **Sublimatory**, that is the method by which you advertise the development server
  * [**Bonjour**](https://developer.apple.com/bonjour/) via [SublimationBonjour](https://github.com/brightdigit/SublimationBonjour)  
  * [**Ngrok**](https://ngrok.com/) via [SublimationNgrok](https://github.com/brightdigit/SublimationBonjour) _which is only needed if you need to advertise your address publicaly_ 
* How it connects to the server
  * [Lifecycle Handler for Vapor](https://docs.vapor.codes/advanced/services/#lifecycle) via [SublimationVapor](https://github.com/brightdigit/SublimationBonjour)
  * [Lifecycle Service](https://github.com/swift-server/swift-service-lifecycle) via [SublimationService](https://github.com/brightdigit/SublimationBonjour) _for server frameworks such as [Hummingbird](https://docs.hummingbird.codes/2.0/documentation/hummingbird/)_

### Example

For instance if you were using Bonjour with Hummingbird and an iOS app your package may look something like this:

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

If you were to use Vapor and Ngrok instead, it'd look more like this:

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

Please check the respective package documentation from the <doc:Package-Ecosystem> section.

## Topics

- ``Sublimation``
