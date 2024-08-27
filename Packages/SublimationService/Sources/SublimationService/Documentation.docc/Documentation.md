# ``SublimationService``

Using `Sublimation` as Lifecycle Service for application such as Hummingbird.

## Overview

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

