/**
 A protocol that defines the configuration for Ngrok in a Vapor application.

 This protocol inherits from `NgrokServerConfiguration`.

 To conform to this protocol, implement the `init(application:)` initializer.

 Example usage:
 ```
 struct MyNgrokConfiguration: NgrokVaporConfiguration {
   init(application: Application) {
     // Configure Ngrok settings here
   }
 }
 ```

 - Note: This protocol is public.
 */
import Vapor

public protocol NgrokVaporConfiguration: NgrokServerConfiguration {
  /**
   Initializes a new instance of the configuration.

   - Parameter application: The Vapor application.

   - Note: This initializer is required to conform to the `NgrokVaporConfiguration` protocol.
   */
  init(application: Application)
}
