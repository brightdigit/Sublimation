//
//  AvailableService.swift
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

// import Foundation
// import Network
// import Observation
//
// @available(*, deprecated)
// public struct AvailableService {
//  public  init(key: String, baseURL: URL) {
//    self.key = key
//    self.baseURL = baseURL
//  }
//
//  public let key : String
//  public let baseURL : URL
// }
//
// @available(*, deprecated)
// extension AvailableService {
//  public init?(result: NWBrowser.Result) {
//    guard case let .service(key, _, _, _) = result.endpoint else {
//      return nil
//    }
//    guard case let .bonjour(txtRecord) =  result.metadata else {
//      return nil
//    }
//    guard case let .string(urlString) = txtRecord.getEntry(for: "Sublimation") else {
//      return nil
//    }
//    guard let baseURL = URL(string: urlString) else {
//      return nil
//    }
//    self.init(key: key, baseURL: baseURL)
//  }
// }
