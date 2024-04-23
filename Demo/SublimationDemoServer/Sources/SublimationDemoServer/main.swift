import SublimationDemoConfiguration
import Network
import SublimationVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}

app.get { _ in
  "You're connected"
}

app.lifecycle.use(
  SublimationLifecycleHandler(
  )
)

#if os(macOS)
if let name = Host.current().addresses.first(where: { address in
  guard address != "127.0.0.1" else {
    return false
  }
  return !address.contains(":")
}) {
  app.http.server.configuration.hostname = name
}
#endif

try app.run()
