//import Foundation
//import Network
//import Observation
//
//@available(*, deprecated)
//public struct AvailableService {
//  public  init(key: String, baseURL: URL) {
//    self.key = key
//    self.baseURL = baseURL
//  }
//  
//  public let key : String
//  public let baseURL : URL
//}
//
//@available(*, deprecated)
//extension AvailableService {
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
//}
