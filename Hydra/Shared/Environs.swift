import Foundation

final class Environs {

  static let env = ProcessInfo.processInfo.environment

  static var stubTrendService: Bool {
    return env.keys.contains("STUB_TREND_SERVICE")
  }

}
