import Vapor
import SublimationDemoConfiguration
import Sublimation
import SublimationVapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Vapor.Application(env)
defer {
  app.shutdown()
}

app.get { _ in
  "You're connected"
}

#if os(macOS) && DEBUG
  app.lifecycle.use(
    Sublimation()
  )
#endif

app.http.server.configuration.hostname = "::"
try app.run()
