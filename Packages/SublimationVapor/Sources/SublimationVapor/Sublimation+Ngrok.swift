//
//  Sublimation+Ngrok.swift
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

////
////  Sublimation+Ngrok.swift
////  Sublimation
////
////  Created by Leo Dion.
////  Copyright © 2024 BrightDigit.
////
////  Permission is hereby granted, free of charge, to any person
////  obtaining a copy of this software and associated documentation
////  files (the “Software”), to deal in the Software without
////  restriction, including without limitation the rights to use,
////  copy, modify, merge, publish, distribute, sublicense, and/or
////  sell copies of the Software, and to permit persons to whom the
////  Software is furnished to do so, subject to the following
////  conditions:
////
////  The above copyright notice and this permission notice shall be
////  included in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
////  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
////  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
////  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
////  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
////  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
////  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
////  OTHER DEALINGS IN THE SOFTWARE.
////
//
// public import Ngrokit
// public import NIOCore
// import OpenAPIAsyncHTTPClient
// public import OpenAPIRuntime
// public import Sublimation
// import SublimationTunnel
// import Vapor
//
// #if os(macOS)
//  extension Sublimation {
//    ///     Initializes the Sublimation lifecycle handler using Ngrok with default values for macOS.
//    ///
//    ///     - Parameters:
//    ///       - ngrokPath: The path to the Ngrok executable.
//    ///       - bucketName: The name of the bucket for the tunnel repository.
//    ///       - key: The key for the tunnel repository.
//    ///
//    ///     - Note: This initializer is only available on macOS.
//    ///
//    ///     - SeeAlso: `KVdbTunnelRepositoryFactory`
//    ///     - SeeAlso: `NgrokCLIAPIServerFactory`
//    public convenience init(
//      ngrokPath: String,
//      bucketName: String,
//      key: some Sendable,
//      isConnectionRefused: @escaping @Sendable (ClientError) -> Bool,
//      ngrokClient: @escaping @Sendable () -> NgrokClient
//    ) {
//      self.init(
//        sublimatory: TunnelSublimatory(
//          ngrokPath: ngrokPath,
//          bucketName: bucketName,
//          key: key,
//          isConnectionRefused: isConnectionRefused,
//          ngrokClient: ngrokClient
//        )
//      )
//    }
//
//    /// Description Initializes the Sublimation lifecycle handler using Ngrok with default values for macOS.
//    ///     - Parameters:
//    ///       - ngrokPath: The path to the Ngrok executable.
//    ///       - bucketName: The name of the bucket for the tunnel repository.
//    ///       - key: The key for the tunnel repository.
//    ///       - timeout: The amount of to wait for the ngrok to respond.
//    public convenience init(
//      ngrokPath: String,
//      bucketName: String,
//      key: some Sendable,
//      timeout: TimeAmount = .seconds(1)
//    ) {
//      let tunnelSublimatory = TunnelSublimatory(
//        ngrokPath: ngrokPath,
//        bucketName: bucketName,
//        key: key,
//        timeout: timeout
//      )
//      self.init(sublimatory: tunnelSublimatory)
//    }
//  }
// #endif
