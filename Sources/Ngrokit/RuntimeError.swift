import Foundation

public enum RuntimeError: Error {
  case invalidURL(String)
  case earlyTermination(TerminationReason, Int?)
  case invalidErrorData(Data)
}
