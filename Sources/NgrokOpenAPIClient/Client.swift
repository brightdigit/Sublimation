// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
  @preconcurrency import struct Foundation.Data
  @preconcurrency import struct Foundation.Date
  @preconcurrency import struct Foundation.URL
#else
  import struct Foundation.Data
  import struct Foundation.Date
  import struct Foundation.URL
#endif
import HTTPTypes
package struct Client: APIProtocol {
  /// The underlying HTTP client.
  private let client: UniversalClient
  /// Creates a new client.
  /// - Parameters:
  ///   - serverURL: The server URL that the client connects to. Any server
  ///   URLs defined in the OpenAPI document are available as static methods
  ///   on the ``Servers`` type.
  ///   - configuration: A set of configuration values for the client.
  ///   - transport: A transport that performs HTTP operations.
  ///   - middlewares: A list of middlewares to call before the transport.
  package init(
    serverURL: Foundation.URL,
    configuration: Configuration = .init(),
    transport: any ClientTransport,
    middlewares: [any ClientMiddleware] = []
  ) {
    self.client = .init(
      serverURL: serverURL,
      configuration: configuration,
      transport: transport,
      middlewares: middlewares
    )
  }

  private var converter: Converter {
    client.converter
  }

  /// Access the root API resource of a running ngrok agent
  ///
  /// - Remark: HTTP `GET /api`.
  /// - Remark: Generated from `#/paths//api/get`.
  package func get_sol_api(_ input: Operations.get_sol_api.Input) async throws -> Operations.get_sol_api.Output {
    try await client.send(
      input: input,
      forOperation: Operations.get_sol_api.id,
      serializer: { _ in
        let path = try converter.renderedPath(
          template: "/api",
          parameters: []
        )
        var request: HTTPTypes.HTTPRequest = .init(
          soar_path: path,
          method: .get
        )
        suppressMutabilityWarning(&request)
        return (request, nil)
      },
      deserializer: { response, responseBody in
        switch response.status.code {
        case 200:
          return .ok(.init())

        default:
          return .undocumented(
            statusCode: response.status.code,
            .init(
              headerFields: response.headerFields,
              body: responseBody
            )
          )
        }
      }
    )
  }

  /// List Tunnels
  ///
  /// - Remark: HTTP `GET /api/tunnels`.
  /// - Remark: Generated from `#/paths//api/tunnels/get(listTunnels)`.
  package func listTunnels(_ input: Operations.listTunnels.Input) async throws -> Operations.listTunnels.Output {
    try await client.send(
      input: input,
      forOperation: Operations.listTunnels.id,
      serializer: { input in
        let path = try converter.renderedPath(
          template: "/api/tunnels",
          parameters: []
        )
        var request: HTTPTypes.HTTPRequest = .init(
          soar_path: path,
          method: .get
        )
        suppressMutabilityWarning(&request)
        converter.setAcceptHeader(
          in: &request.headerFields,
          contentTypes: input.headers.accept
        )
        return (request, nil)
      },
      deserializer: { response, responseBody in
        switch response.status.code {
        case 200:
          let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
          let body: Operations.listTunnels.Output.Ok.Body
          let chosenContentType = try converter.bestContentType(
            received: contentType,
            options: [
              "application/json"
            ]
          )
          switch chosenContentType {
          case "application/json":
            body = try await converter.getResponseBodyAsJSON(
              Components.Schemas.TunnelList.self,
              from: responseBody,
              transforming: { value in
                .json(value)
              }
            )

          default:
            preconditionFailure("bestContentType chose an invalid content type.")
          }
          return .ok(.init(body: body))

        default:
          return .undocumented(
            statusCode: response.status.code,
            .init(
              headerFields: response.headerFields,
              body: responseBody
            )
          )
        }
      }
    )
  }

  /// Start tunnel
  ///
  /// - Remark: HTTP `POST /api/tunnels`.
  /// - Remark: Generated from `#/paths//api/tunnels/post(startTunnel)`.
  package func startTunnel(_ input: Operations.startTunnel.Input) async throws -> Operations.startTunnel.Output {
    try await client.send(
      input: input,
      forOperation: Operations.startTunnel.id,
      serializer: { input in
        let path = try converter.renderedPath(
          template: "/api/tunnels",
          parameters: []
        )
        var request: HTTPTypes.HTTPRequest = .init(
          soar_path: path,
          method: .post
        )
        suppressMutabilityWarning(&request)
        converter.setAcceptHeader(
          in: &request.headerFields,
          contentTypes: input.headers.accept
        )
        let body: OpenAPIRuntime.HTTPBody?
        switch input.body {
        case let .json(value):
          body = try converter.setRequiredRequestBodyAsJSON(
            value,
            headerFields: &request.headerFields,
            contentType: "application/json; charset=utf-8"
          )
        }
        return (request, body)
      },
      deserializer: { response, responseBody in
        switch response.status.code {
        case 201:
          let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
          let body: Operations.startTunnel.Output.Created.Body
          let chosenContentType = try converter.bestContentType(
            received: contentType,
            options: [
              "application/json"
            ]
          )
          switch chosenContentType {
          case "application/json":
            body = try await converter.getResponseBodyAsJSON(
              Components.Schemas.TunnelResponse.self,
              from: responseBody,
              transforming: { value in
                .json(value)
              }
            )

          default:
            preconditionFailure("bestContentType chose an invalid content type.")
          }
          return .created(.init(body: body))

        default:
          return .undocumented(
            statusCode: response.status.code,
            .init(
              headerFields: response.headerFields,
              body: responseBody
            )
          )
        }
      }
    )
  }

  /// Tunnel detail
  ///
  /// - Remark: HTTP `GET /api/tunnels/{name}`.
  /// - Remark: Generated from `#/paths//api/tunnels/{name}/get(getTunnel)`.
  package func getTunnel(_ input: Operations.getTunnel.Input) async throws -> Operations.getTunnel.Output {
    try await client.send(
      input: input,
      forOperation: Operations.getTunnel.id,
      serializer: { input in
        let path = try converter.renderedPath(
          template: "/api/tunnels/{}",
          parameters: [
            input.path.name
          ]
        )
        var request: HTTPTypes.HTTPRequest = .init(
          soar_path: path,
          method: .get
        )
        suppressMutabilityWarning(&request)
        converter.setAcceptHeader(
          in: &request.headerFields,
          contentTypes: input.headers.accept
        )
        return (request, nil)
      },
      deserializer: { response, responseBody in
        switch response.status.code {
        case 200:
          let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
          let body: Operations.getTunnel.Output.Ok.Body
          let chosenContentType = try converter.bestContentType(
            received: contentType,
            options: [
              "application/json"
            ]
          )
          switch chosenContentType {
          case "application/json":
            body = try await converter.getResponseBodyAsJSON(
              OpenAPIRuntime.OpenAPIValueContainer.self,
              from: responseBody,
              transforming: { value in
                .json(value)
              }
            )

          default:
            preconditionFailure("bestContentType chose an invalid content type.")
          }
          return .ok(.init(body: body))

        default:
          return .undocumented(
            statusCode: response.status.code,
            .init(
              headerFields: response.headerFields,
              body: responseBody
            )
          )
        }
      }
    )
  }

  /// Stop tunnel
  ///
  /// - Remark: HTTP `DELETE /api/tunnels/{name}`.
  /// - Remark: Generated from `#/paths//api/tunnels/{name}/delete(stopTunnel)`.
  package func stopTunnel(_ input: Operations.stopTunnel.Input) async throws -> Operations.stopTunnel.Output {
    try await client.send(
      input: input,
      forOperation: Operations.stopTunnel.id,
      serializer: { input in
        let path = try converter.renderedPath(
          template: "/api/tunnels/{}",
          parameters: [
            input.path.name
          ]
        )
        var request: HTTPTypes.HTTPRequest = .init(
          soar_path: path,
          method: .delete
        )
        suppressMutabilityWarning(&request)
        return (request, nil)
      },
      deserializer: { response, responseBody in
        switch response.status.code {
        case 204:
          return .noContent(.init())

        default:
          return .undocumented(
            statusCode: response.status.code,
            .init(
              headerFields: response.headerFields,
              body: responseBody
            )
          )
        }
      }
    )
  }
}
