import Vapor

extension URI {
  init(components: URLComponents) {
    self.init(
      scheme: .init(components.scheme),
      host: components.host,
      port: components.port,
      path: components.path,
      query: components.query,
      fragment: components.fragment
    )
  }
}
