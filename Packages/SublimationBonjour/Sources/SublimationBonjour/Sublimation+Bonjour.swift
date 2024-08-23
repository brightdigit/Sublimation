//
//  Sublimation+Bonjour.swift
//  SublimationBonjour
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

#if canImport(Network)
  public import Network
  public import Sublimation
  public import Logging

  extension Sublimation {
    /// Initializes a `Sublimation` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - bindingConfiguration: A configuration with addresses, port and tls configuration.
    ///   - name: Service name.
    ///   - type: Service type.
    ///   - listenerParameters: The network parameters to use for the listener. Default is `.tcp`.
    ///   - logger: <#logger description#>
    ///   - listenerQueue: <#listenerQueue description#>
    ///   - connectionQueue: <#connectionQueue description#>
    ///
    public convenience init(
      bindingConfiguration: BindingConfiguration,
      logger: Logger,
      name: String = BonjourSublimatory.defaultName,
      type: String = BonjourSublimatory.defaultHttpTCPServiceType,
      listenerParameters: NWParameters = .tcp,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) throws {
      let sublimatory = try BonjourSublimatory(
        bindingConfiguration: bindingConfiguration,
        logger: logger,
        parameters: listenerParameters,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
      self.init(sublimatory: sublimatory)
    }
    public convenience init(
      bindingConfiguration: BindingConfiguration,
      logger: Logger,
      listener: NWListener,
      name: String = BonjourSublimatory.defaultName,
      type: String = BonjourSublimatory.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) throws {
      let sublimatory = BonjourSublimatory(
        bindingConfiguration: bindingConfiguration,
        logger: logger,
        listener: listener,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
      self.init(sublimatory: sublimatory)
    }
  }
#endif
