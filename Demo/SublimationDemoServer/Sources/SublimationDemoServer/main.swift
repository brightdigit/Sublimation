import Vapor
import Sublimation

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
  Sublimation()
)


app.http.server.configuration.hostname = "::"
try app.run()
