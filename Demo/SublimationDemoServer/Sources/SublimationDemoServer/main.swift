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


app.lifecycle.use(
  Sublimation(
    ngrokPath: Configuration.ngrokPath,
    bucketName: Configuration.bucketName,
    key: Configuration.key
  )
#endif


app.http.server.configuration.hostname = "::"
try app.run()
