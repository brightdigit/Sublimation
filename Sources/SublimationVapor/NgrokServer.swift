/**
 A protocol for starting a Ngrok server.

 Implement this protocol to start a Ngrok server.

 - Note: The Ngrok server allows you to expose a local server to the internet.

 - Important: Make sure to call the `start()` method to start the Ngrok server.
 */
public protocol NgrokServer {
  /**
   Starts the Ngrok server.

   Call this method to start the Ngrok server and expose your local server to the internet.
   */
  func start()
}
