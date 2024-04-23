import SublimationDemoConfiguration
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

try app.run()
