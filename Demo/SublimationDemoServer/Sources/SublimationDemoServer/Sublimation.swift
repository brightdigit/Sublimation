import Sublimation
import Vapor

extension Sublimation : LifecycleHandler {
  public func willBoot(_ application: Vapor.Application) throws {
    Task {
     self.willBoot{application}
    }
  }
  
  public func didBoot(_ application: Vapor.Application) throws {
    Task {
      self.didBoot{application}
    }
    
  }
  
  public func shutdown(_ application: Vapor.Application) {
    Task {
      self.shutdown{application}
    }
  }
}
