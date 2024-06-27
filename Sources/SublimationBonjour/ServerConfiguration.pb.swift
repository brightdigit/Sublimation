//
//  ServerConfiguration.pb.swift
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

// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: ProtoBuf/ServerConfiguration.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

package struct ServerConfiguration {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  package var isSecure: Bool = false

  package var port: UInt32 = 0

  package var hosts: [String] = []

  package var unknownFields = SwiftProtobuf.UnknownStorage()

  package init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
  extension ServerConfiguration: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ServerConfiguration: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  package static let protoMessageName: String = "ServerConfiguration"
  package static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "is_secure"),
    2: .same(proto: "port"),
    9: .same(proto: "hosts")
  ]

  package mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try decoder.decodeSingularBoolField(value: &self.isSecure)
      case 2: try decoder.decodeSingularUInt32Field(value: &self.port)
      case 9: try decoder.decodeRepeatedStringField(value: &self.hosts)
      default: break
      }
    }
  }

  package func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
    if self.isSecure != false {
      try visitor.visitSingularBoolField(value: self.isSecure, fieldNumber: 1)
    }
    if self.port != 0 {
      try visitor.visitSingularUInt32Field(value: self.port, fieldNumber: 2)
    }
    if !self.hosts.isEmpty {
      try visitor.visitRepeatedStringField(value: self.hosts, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  package static func == (lhs: ServerConfiguration, rhs: ServerConfiguration) -> Bool {
    if lhs.isSecure != rhs.isSecure { return false }
    if lhs.port != rhs.port { return false }
    if lhs.hosts != rhs.hosts { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
