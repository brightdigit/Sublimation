//
//  NgrokCLIAPIConfiguration.swift
//  Sublimation
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

import Logging
import Vapor

internal protocol ServerApplication {
  var httpServerConfigurationPort : Int { get }
  var logger : Logger { get }
}

extension Vapor.Application : ServerApplication {
  var httpServerConfigurationPort: Int {
    http.server.configuration.port
  }
  
  
}

public struct NgrokCLIAPIConfiguration: NgrokServerConfiguration {
  public typealias Server = NgrokCLIAPIServer
  public let port: Int
  public let logger: Logger
}

extension NgrokCLIAPIConfiguration: NgrokVaporConfiguration {
  internal init(serverApplication: any ServerApplication) {
    self.init(
      port: serverApplication.httpServerConfigurationPort,
      logger: serverApplication.logger
    )
    
  }
  
  public init(application: Vapor.Application) {
    self.init(serverApplication: application)
  }
}
