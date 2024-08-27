# ``Ngrokit``

Swift API for [Ngrok Agent API](https://ngrok.com/docs/agent/api/).

## Overview

Ngrokit is an easy to use Swift library for call the Swift API for [Ngrok Agent API](https://ngrok.com/docs/agent/api/) as well as running the `ngrok` command. 

### Connecting to the Local REST API

Using the ``NgrokClient`` to connect to your local development server:

```swift
let client = NgrokClient(transport: URLSession.shared)
```

For using different transports see the client list at the [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator?tab=readme-ov-file#package-ecosystem). 

### Starting the CLI Process.

Start the CLI process by using ``NgrokProcessCLIAPI``:

```swift
let cliAPI = NgrokProcessCLIAPI(ngrokPath: "/usr/local/bin/ngrok")
let process = api.process(forHTTPPort: 100)
process.run { let error in
  print(error)
}
```

## Topics

### Consuming Ngrok API

- ``NgrokClient``
- ``NgrokProcessCLIAPI``

### Data Structures

- ``NgrokTunnel``
- ``TunnelRequest``
- ``NgrokTunnelConfiguration``

### Errors

- ``RuntimeError``
- ``NgrokError``
- ``TerminationReason``

### Process Components

- ``NgrokProcess``
- ``NgrokCLIAPI``
- ``Processable``
- ``ProcessableProcess``
- ``Pipable``
- ``DataHandle``
