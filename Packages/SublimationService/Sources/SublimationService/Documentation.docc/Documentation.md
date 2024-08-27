# ``SublimationService``

Using [Sublimation](https://github.com/brightdigit/Sublimation) as a [Lifecycle Service](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/2.6.1/documentation/servicelifecycle) for applications such as [Hummingbird](https://github.com/hummingbird-project/hummingbird).

## Overview

![SublimationService Logo](SublimationService.svg)

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

