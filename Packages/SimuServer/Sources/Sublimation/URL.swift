//
//  File.swift
//  
//
//  Created by Leo Dion on 11/14/22.
//

import Foundation

extension URL : KVdbURLConstructable {
  public init(kvDBBase: String, keyBucketPath: String) {
    self = URL(string: kvDBBase)!.appendingPathComponent(keyBucketPath)
  }
}
