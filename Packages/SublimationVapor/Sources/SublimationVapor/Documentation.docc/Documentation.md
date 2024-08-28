# ``SublimationVapor``

Using [Sublimation](https://github.com/brightdigit/Sublimation) as a [LifecycleHandler](https://docs.vapor.codes/advanced/services/#lifecycle) for [Vapor](https://vapor.codes).

## Overview

![SublimationVapor Logo](SublimationVapor.svg)

For [Vapor](https://vapor.codes), you add it to the lifecycle of the app:

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
