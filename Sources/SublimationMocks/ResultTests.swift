
package enum MockError<T: Equatable & Sendable>: Error {
  case value(T)
}

extension Result {
  package func mockErrorValue<T: Equatable & Sendable>() -> T? {
    guard let mockError = error as? MockError<T> else {
      return nil
    }

    switch mockError {
    case let .value(value):
      return value
    }
  }

  package var error: (any Error)? {
    guard case let .failure(failure) = self else {
      return nil
    }
    return failure
  }
}
