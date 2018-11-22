import UIKit

import RxSwift

import JacKit
import MudoxKit

import SwiftyUserDefaults

private let jack = Jack("AppFlow").set(format: .short)

extension PrimitiveSequenceType where TraitType == CompletableTrait, ElementType == Swift.Never {

  func neverComplete() -> Disposable {
    return subscribe(
      onCompleted: {
        jack.error("should never complete")
      },
      onError: {
        jack.error("should never fail, error: \($0)")
      }
    )
  }

}

class AppFlow: BaseAppFlow {

  override func start() {
    super.start()

    resetIfNeeded()

//    _ = welcomeIfNeeded
//      .andThen(loginIfNeeded)
//      .andThen(startMainFlow)
//      .neverComplete()

//    let flow = TrendFlow(stage: stage)
//    _ = flow.start()
//      .neverComplete()

    _ = startMainFlow.neverComplete()

  }

  /// Reset app states for developing purpose
  ///
  /// Reset according to the value of environment variable `RESET_APP`:
  /// - "all":  reset all app data
  private func resetIfNeeded() {
    #if DEBUG
      switch ProcessInfo.processInfo.environment["RESET_APP"] {
      case "all":
        jack.descendant("start").debug("clear data in UserDefaults")
        Defaults.removeAll()
      default:
        break
      }
    #endif
  }

  private var welcomeIfNeeded: Completable {
    _ = FirstLaunchChecker.shared.check()
    jack.descendant("welcomeIfNeeded").warn("not implemented yet")

    return .empty()
  }

  private var loginIfNeeded: Completable {
    let flow = LoginFlow(stage: stage, credentialService: CredentialService.shared)
    return flow.loginIfNeeded()
  }

  var startMainFlow: Completable {
    let tabBarController = UITabBarController()
    stage.window.rootViewController = tabBarController

    // Trend
    let trendFlow = TrendFlow(stage: .viewController(tabBarController))
    return trendFlow.start()
  }
}
