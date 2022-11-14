//
// NgrokTunnel.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Foundation
import Prch

extension FileHandle {
  
  
  func parseNgrokErrorCode() throws -> Int? {
    
    guard let data = try self.readToEnd() else {
      return nil
    }
    
    guard let text = String(data: data, encoding: .utf8) else {
      throw Ngrok.CLI.RunError.invalidErrorData(data)
    }
    
    guard let match = Ngrok.CLI.errorRegex.firstMatch(in: text, range: .init(location: 0, length: text.count)), match.numberOfRanges > 0 else {
      return nil
    }
    
    
    guard let range = Range(match.range(at: 1), in: text) else {
      return nil
    }
          return Int(text[range])
        
  }
}
