import Vapor

public protocol NgrokVaporConfiguration: NgrokServerConfiguration {
  init(application: Application)
}
