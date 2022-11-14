import Vapor
import SublimationVapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}
try configure(app)
app.lifecycle.use(NgrokLifecycleHandler(
  bucketName: "4WwQUN9AZrppSyLkbzidgo", key: "hello"
))
try app.start()
