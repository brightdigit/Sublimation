//
// NgrokTunnel.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Foundation
import Prch

public enum Ngrok {
  public struct API : Prch.API {
    
    public let baseURL: URL
    
    public let headers = [String : String]()
    
    public let decoder : ResponseDecoder = JSONDecoder()
    
    public var encoder : RequestEncoder = JSONEncoder()
    
    public enum Error : Swift.Error {
      case tunnelNotFound
    }
  }
  
  
  public struct CLI {
    let executableURL : URL
    
    public enum RunError : Error {
      case earlyTermination(Process.TerminationReason?)
    }
    public func http(port: Int, timeout: DispatchTime) async throws {
      let process = Process()
      let semaphore = DispatchSemaphore(value: 0)
      process.executableURL = executableURL
      process.terminationHandler = { process in
        semaphore.signal()
      }
      try process.run()
      try await withCheckedThrowingContinuation { continuation in
        let result : Result<Void, Error>
        let semaphoreResult = semaphore.wait(timeout: timeout)
        result = semaphoreResult == .success ? .failure(RunError.earlyTermination(process.terminationReason)) : .success(())
        continuation.resume(with: result)
      }
    }
  }
}

public struct ListTunnelsResponse : Response {
  public let response: Prch.ClientResult<NgrokTunnelResponse, Never>
  
  public typealias SuccessType = NgrokTunnelResponse
  
  public typealias FailureType = Never
  
  public typealias APIType = Ngrok.API
  
  public var statusCode: Int
  
  public init(statusCode: Int, data: Data, decoder: Prch.ResponseDecoder) throws {
    self.statusCode = statusCode
    self.response = try .success(decoder.decode(SuccessType.self, from: data))
  }
  
  public var debugDescription: String {
    return self.response.debugDescription
  }
  
  public var description: String {
    return self.response.description
  }
  
}



public struct ListTunnelsRequest : Request {
  
  
  public typealias ResponseType = ListTunnelsResponse
  
  public let method: String = "GET"
  
  public let path = "api/tunnels"
  
  public let queryParameters = [String : Any]()
  
  public let  headers = [String : String] ()
  
  public let encodeBody: ((Prch.RequestEncoder) throws -> Data)? = nil
  
  public let name: String = ""
  
  
}

public struct StateTunnelResponse : Response {
  public let response: ClientResult<NgrokTunnel, Never>
  
  public typealias SuccessType = NgrokTunnel
  
  public typealias FailureType = Never
  
  public typealias APIType = Ngrok.API
  
  public var statusCode: Int
  
  public init(statusCode: Int, data: Data, decoder: Prch.ResponseDecoder) throws {
    self.statusCode = statusCode
    self.response = try .success(decoder.decode(SuccessType.self, from: data))
  }
  
  public var debugDescription: String {
    return self.response.debugDescription
  }
  
  public var description: String {
    return self.response.description
  }
  
  
}

public struct StopTunnelResponse : Response {
  public let response: Prch.ClientResult<Void, FailureType>
  
  public typealias SuccessType = Void
  
  public typealias FailureType = Ngrok.API.Error
  
  public typealias APIType = Ngrok.API
  
  public var statusCode: Int
  
  public init(statusCode: Int, data: Data, decoder: Prch.ResponseDecoder) throws {
    
    self.statusCode = statusCode
    self.response = statusCode == 204 ? .success(()) : .defaultResponse(statusCode, .tunnelNotFound)
  }
  
  public var debugDescription: String {
    response.debugDescription
  }
  
  public var description: String {
    response.description
  }
  
  
}
public struct StopTunnelRequest : Request {
  public typealias ResponseType = StopTunnelResponse
  
  public var method: String
  
  public var path: String
  
  public var queryParameters: [String : Any]
  
  public var headers: [String : String]
  
  public var encodeBody: ((Prch.RequestEncoder) throws -> Data)?
  
  public var name: String
  
  
}

public struct NgrokTunnelRequest : Codable {
  internal init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }
  
  public init (port: Int, proto : String = "http", name: String = "vapor-development") {
    self.init(addr: port.description, proto: proto, name: name)
  }
  
  let addr : String
  let proto : String
  let name : String
}
public struct NgrokTunnelConfiguration : Codable {
  
  let addr : URL
  let inspect : Bool
}
public struct NgrokTunnel: Codable {
  public let name : String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config : NgrokTunnelConfiguration

}
