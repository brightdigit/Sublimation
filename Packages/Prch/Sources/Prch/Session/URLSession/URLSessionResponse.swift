import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLSession {
  public struct Response: SessionResponse {
    public typealias DataType = Data

    internal init(httpURLResponse: HTTPURLResponse, data: Data) {
      self.httpURLResponse = httpURLResponse
      self.data = data
    }

    let httpURLResponse: HTTPURLResponse
    public let data: Data

    public var statusCode: Int {
      httpURLResponse.statusCode
    }
  }
}

extension URLSession.Response {
  internal init(_ tuple: (Data, URLResponse)) throws {
    try self.init(urlResponse: tuple.1, data: tuple.0)
  }

  internal init(urlResponse: URLResponse, data: Data) throws {
    guard let response = urlResponse as? HTTPURLResponse else {
      throw RequestError.invalidResponse(urlResponse)
    }
    self.init(httpURLResponse: response, data: data)
  }

  internal init?(error: Error?, data: Data?, urlResponse: URLResponse?) throws {
    if let error = error {
      throw error
    }

    guard let urlResponse = urlResponse, let data = data else {
      return nil
    }

    try self.init(urlResponse: urlResponse, data: data)
  }
}
