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
    ngrokPath: Configuration.ngrokPath,
    bucketName: Configuration.bucketName,
    key: Configuration.key
  )
)

try app.run()
