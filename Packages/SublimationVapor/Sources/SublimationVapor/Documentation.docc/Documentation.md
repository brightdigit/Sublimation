# ``SublimationVapor``

Using `Sublimation` as `LifecycleHandler` for `Vapor`.

## Overview

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
