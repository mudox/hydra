import Foundation

final class EnvService {
  
  let env = ProcessInfo.processInfo.environment

  var stubTrendService: Bool {
    return env.keys.contains("STUB_TREND_SERVICE")
  }
  
  
}
