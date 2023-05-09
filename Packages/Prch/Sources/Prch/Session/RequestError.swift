import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum RequestError: Error {
  case missingData
  case invalidResponse(URLResponse?)
  case invalidStatusCode(Int)
}
