import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequest: SessionRequest {
  public typealias DataType = Data
}
