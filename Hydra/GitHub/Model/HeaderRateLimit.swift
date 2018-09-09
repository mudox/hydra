import Foundation
import Moya

import MudoxKit

import RxCocoa
import RxSwift

extension GitHub {

  struct RateLimit {

    // MARK: - Stored Properties

    let remainingCount: Int
    let totalCount: Int
    let resetTimeIntervalSince1970: TimeInterval

    // MARK: - Initializer

    init?(from headers: [String: String]) {
      guard
        let limit = headers["X-RateLimit-Limit"],
        let totalCount = Int(limit),
        let remaining = headers["X-RateLimit-Remaining"],
        let remainingCount = Int(remaining),
        let reset = headers["X-RateLimit-Reset"],
        let resetTimeInterval = TimeInterval(reset)
      else {
        return nil
      }

      self.totalCount = totalCount
      self.remainingCount = remainingCount
      resetTimeIntervalSince1970 = resetTimeInterval
    }

    // MARK: - Computed Properties

    var isExceeded: Bool {
      return remainingCount > 0
    }

    var resetInterval: TimeInterval {
      return resetTimeIntervalSince1970 - Date().timeIntervalSince1970
    }

  }

}

// MARK: - CustomReflectable

extension GitHub.RateLimit: CustomReflectable {

  var customMirror: Mirror {
    return Mirror(
      GitHub.RateLimit.self,
      children: [
        "remain": remainingCount,
        "total": totalCount,
        "reset": "in \(Int(resetInterval))s",
      ]
    )
  }

}
