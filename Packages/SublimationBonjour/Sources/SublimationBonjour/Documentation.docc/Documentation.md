# ``SublimationBonjour``

Use Bonjour for automatic discovery of your Swift Server.

![SublimationBonjour Diagram](SublimationBonjour.svg)

## Overview

When the Swift Server begins it will tell Sublimation the ip addresses or host names which are available to access the server from (including the port number and whether to use https or http). This is called a ``BonjourSublimatory``. The ``BonjourSublimatory`` then uses ``NWListener`` to advertise this information both by send the data encoded using Protocol Buffers as well as inside the Text Record advertised.


### Setting up your Server

Create a ``BindingConfiguration`` using ``BindingConfiguration/init(hosts:port:isSecure:)``:

* a list of host names and ip address
* port number of the server
* whether the server uses https or http

```
let bindingConfiguration = BindingConfiguration(
  host: ["Leo's-Mac.local", "192.168.1.10"],
  port: 8080
  isSecure: false
)
```

Create a ``BonjourSublimatory`` with ``BonjourSublimatory/init(bindingConfiguration:logger:parameters:name:type:listenerQueue:connectionQueue:)`` using that ``BindingConfiguration`` and include your server's logger. Then attach it to the `Sublimation` object:

```
let bonjour = BonjourSublimatory(
  bindingConfiguration: bindingConfiguration,
  logger: app.logger
)
let sublimation = Sublimation(sublimatory : bonjour)
```

### Setting up your Client

The iPhone or Apple Watch then uses a ``BonjourClient`` to fetch either an `AsyncStream` of `URL` with ``BonjourClient/urls`` or simply get the ``BonjourClient/first()`` one available:

```
let client = BonjourClient(logger: app.logger)
let hostURL = await client.first()
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
