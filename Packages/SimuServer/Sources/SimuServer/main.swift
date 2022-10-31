import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}
app.lifecycle.use(NgrokLifecycleHandler())
try configure(app)
try app.start()

struct NgrokLifecycleHandler : LifecycleHandler {
  let ngrokProcess : Process
  
  init () {
    let ngrokProcess = Process ()
    ngrokProcess.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ngrok")
    self.ngrokProcess = ngrokProcess
  }
  
  func saveTunnel () throws {
    let serverName = "hello"
    let bucketName = "4WwQUN9AZrppSyLkbzidgo"

    let decoder = JSONDecoder()
    ngrokProcess.arguments = ["http", app.http.server.shared.configuration.port.description]
    try ngrokProcess.run()

    let response = try app.http.client.shared.get(url: NgrokUrlParser.defaultApiURL.absoluteString).flatMapThrowing { response -> NgrokTunnelResponse? in
      guard let body = response.body else {
        return nil
      }
      
      return try decoder.decode(NgrokTunnelResponse.self, from: body)
    }.wait()

    if let url = response?.tunnels.first?.public_url {
      print(url)
      let status = try app.http.client.shared.post(url: "https://kvdb.io/\(bucketName)/\(serverName)", body: .string(url.absoluteString)).wait().status
      print(status)
    }
  }
  func didBoot(_ application: Application) throws {
    try self.saveTunnel()
    
  }
  func shutdown(_ application: Application) {
    self.ngrokProcess.terminate()
  }
  
}



try app.running?.onStop.wait()
