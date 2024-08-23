# SublimationBonjour

Share your local development server easily with your Apple devices via Ngrok.

```mermaid
sequenceDiagram
  participant Server as Hummingbird/Vapor Server
  participant BonjourSub as BonjourSublimatory
  participant NWListener as NWListener
  participant Network as Local Network
  participant BonjourClient as BonjourClient
  participant App as iOS/watchOS App
  
  Server->>BonjourSub: Start server, provide IP addresses,<br/>hostnames, port, and protocol (http/https)
  BonjourSub->>NWListener: Configure with server information
  NWListener->>Network: Advertise service:<br/>1. Send encoded server data<br/>2. Use Text Record for additional info
  App->>BonjourClient: Request server URL
  BonjourClient->>Network: Search for advertised services
  Network-->>BonjourClient: Return advertised service information
  BonjourClient->>BonjourClient: 1. Receive and decode server data<br/>2. Parse Text Record
  BonjourClient-->>App: Return AsyncStream<URL><br/>or first available URL
  App->>Server: Connect to server using discovered URL
```

```swift
let bindingConfiguration = BindingConfiguration(
  host: ["Leo's-Mac.local", "192.168.1.10"],
  port: 8080
  isSecure: false
)
let bonjour = BonjourSublimatory(
  bindingConfiguration: bindingConfiguration,
  logger: app.logger
)
let sublimation = Sublimation(sublimatory : bonjour)
```

## Overview

Ngrok is a fantastic service for setting up local development server for outside access. Let's say you need to share your local development server because you're testing on an actual device which can't access your machine via your local network. You can run `ngrok` to setup an https address which tunnels to your local development server:

```bash
> vapor run serve -p 1337
> ngrok http 1337
```
Now you'll get a message saying your vapor app is served through ngrok:

```
Forwarding https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io -> http://localhost:1337 
```

With Sublimation you save the address (such as `https://c633-2600-1702-4050-7d30-cc59-3ffb-effa-6719.ngrok.io`) to a key-value storage and pull that address from your Apple device during development.

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
