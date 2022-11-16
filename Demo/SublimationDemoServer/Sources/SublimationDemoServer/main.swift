import Vapor
import SublimationVapor
import SublimationDemoConfiguration

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}
app.get { req async in
    "You're connected"
}
app.lifecycle.use(NgrokLifecycleHandler(
  ngrokPath: Configuration.ngrokPath,
  bucketName: Configuration.bucketName,
  key: Configuration.key
))
try app.run()
