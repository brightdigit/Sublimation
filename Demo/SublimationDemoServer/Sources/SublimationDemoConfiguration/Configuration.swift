//
//  File.swift
//  
//
//  Created by Leo Dion on 11/15/22.
//

import Foundation

let yourBucketName : String? = "4WwQUN9AZrppSyLkbzidgo"
let yourKey : String? = "hello"

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
}
