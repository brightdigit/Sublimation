//
//  Vapor.Application.swift
//  SublimationVapor
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import Vapor

public import protocol SublimationCore.Application

extension Vapor.Application: @retroactive Application {
  public var httpServerConfigurationPort: Int { self.http.server.configuration.port }

  public var httpServerTLS: Bool { self.http.server.configuration.tlsConfiguration != nil }

  public func post(to url: URL, body: Data?) async throws {
    _ = try await client.post(.init(string: url.absoluteString)) { request in
      request.body = body.map(ByteBuffer.init(data:))
    }
  }

  public func get(from url: URL) async throws -> Data? {
    let response = try await client.get(.init(string: url.absoluteString))
    return response.body.map { Data(buffer: $0) }
  }
}
