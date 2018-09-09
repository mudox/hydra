import Foundation
import Moya

import MudoxKit

import RxCocoa
import RxSwift

extension GitHub {

  struct RateLimit {

    // MARK: - Stored Properties

    let remaining: Int
    let total: Int
    let resetDate: Date

    // MARK: - Initializer

    init?(from headers: [String: String]) {
      guard
        let limit = headers["X-RateLimit-Limit"],
        let total = Int(limit),
        let remainingString = headers["X-RateLimit-Remaining"],
        let remaining = Int(remainingString),
        let resetString = headers["X-RateLimit-Reset"],
        let resetEpochSeconds = TimeInterval(resetString)
      else {
        return nil
      }

      self.total = total
      self.remaining = remaining
      self.resetDate = Date(timeIntervalSince1970: resetEpochSeconds)
    }

    // MARK: - Computed Properties

    var isExceeded: Bool {
      return remaining > 0
    }

  }

}

// MARK: - CustomReflectable

extension GitHub.RateLimit: CustomReflectable {

  var customMirror: Mirror {
    let interval = resetDate.timeIntervalSinceNow
    
    let fmt = DateComponentsFormatter()
    fmt.allowedUnits = [.day, .hour, .minute, .second]
    fmt.includesTimeRemainingPhrase = true
    fmt.maximumUnitCount = 2
    let resetText = fmt.string(from: interval) ?? "\(interval)s remaining"
    
    return Mirror(
      GitHub.RateLimit.self,
      children: [
        "remain": remaining,
        "total": total,
        "reset": resetText,
      ]
    )
  }

}
