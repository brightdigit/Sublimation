//
//  File.swift
//  
//
//  Created by Leo Dion on 6/5/24.
//

#if canImport(os)
  import os
public typealias Logger = os.Logger
#elseif canImport(Logging)
  import Logging
public typealias Logger = Logging.Logger
#endif


