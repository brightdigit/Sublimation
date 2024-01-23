//
//  APITests.swift
//  
//
//  Created by Leo Dion on 1/23/24.
//

import Foundation
import XCTest
import Ngrokit
import OpenAPIURLSession

final class APITests: XCTestCase {



    func testExample() async throws {
      #if os(macOS)
      
      let cli = Ngrok.CLI(executableURL: .init(filePath:  "/opt/homebrew/bin/ngrok"))
      let process = try await cli.http(port: 8080, timeout: .now() + 10)
      let client = Ngrok.Client(transport: URLSessionTransport())
      let tunnels : [Tunnel]
      do {
         tunnels = try await client.listTunnels()
      } catch {
        dump(error)
        throw error
      }
      guard let tunnel = tunnels.first else {
        XCTAssertNotNil(tunnels.first)
        return
      }
      #else
      
          throw XCTSkip("Required API is not available for this test.")
      #endif
    }


}
