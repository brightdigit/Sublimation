import Foundation

#if os(macOS)
  public typealias TerminationReason = Process.TerminationReason
#else
  public enum TerminationReason: Int {
    case exit = 1

    case uncaughtSignal = 2
  }
#endif
