
import Foundation

public protocol Application {
  func post (to url: URL, body : Data?) async throws
  func get (from url: URL) async throws -> Data?
  
    /// The port number for the HTTP server configuration.
    var httpServerConfigurationPort: Int { get }
  
  var httpServerTLS: Bool { get }
  
    /// The logger for the server application.
    var logger: Logger { get }
  
}

public final class Sublimation : Sendable {
  
  public let sublimatory : any Sublimatory
  
  public init(sublimatory: any Sublimatory) {
    self.sublimatory = sublimatory
  }
  
  public func willBoot(_ application: @Sendable @escaping () -> any Application) {
    Task {
      await self.sublimatory.willBoot(from: application)
    }
  }
  
  public func didBoot(_ application: @Sendable @escaping () -> any Application) {
    Task {
      await self.sublimatory.didBoot(from: application)
    }
  }
  
  public func shutdown(_ application: @Sendable @escaping () -> any Application){
    Task {
      await self.sublimatory.shutdown(from: application)
    }
  }
}

#if canImport(Network)
import Network
extension Sublimation {
  public convenience init (
    listenerParameters: NWParameters = .tcp,
    serviceType: String = BonjourSublimatory.httpTCPServiceType,
                           maximumCount: Int? = nil,
                           addresses: @escaping @Sendable () async -> [String],
                           addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
  ) {
    self.init(
      sublimatory: BonjourSublimatory(listenerParameters: listenerParameters, serviceType: serviceType, maximumCount: maximumCount, addresses: addresses, addressFilter: addressFilter)
    )
  }
  
  #if os(macOS)
  public convenience init (
    listenerParameters: NWParameters = .tcp,
    serviceType: String = BonjourSublimatory.httpTCPServiceType,
                           maximumCount: Int? = nil,
                           addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
  ) {
    self.init(
      listenerParameters: listenerParameters,
      serviceType: serviceType,
      maximumCount: maximumCount,
      addresses: BonjourSublimatory.addressesFromHost,
      addressFilter: addressFilter
    )
  }
  #endif
}
#endif
