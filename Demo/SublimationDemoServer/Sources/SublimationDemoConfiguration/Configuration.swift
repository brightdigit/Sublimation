//
//  File.swift
//  
//
//  Created by Leo Dion on 11/15/22.
//

import Foundation

let yourBucketName : String? = nil
let yourKey : String? = nil
let yourNgrokPath : String = "/opt/homebrew/bin/ngrok"

public enum Configuration {
  public static var bucketName : String {
    guard let bucketName = yourBucketName else {
      preconditionFailure("Please go to \(#filePath) and enter your bucket name from kvdb.io.")
    }
    return bucketName
  }
  
  public static var key : String {
    guard let key = yourKey else {
      preconditionFailure("Please go to \(#filePath) and enter your key from kvdb.io.")
    }
    return key
  }
  
  public static var ngrokPath : String {
    return yourNgrokPath
  }
}