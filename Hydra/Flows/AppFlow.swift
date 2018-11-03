import UIKit

import RxSwift

import JacKit
import MudoxKit

import SwiftyUserDefaults

private let jack = Jack("AppFlow").set(options: .short)

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

    _ = welcomeIfNeeded
      .andThen(loginIfNeeded)
      .andThen(startMainFlow)
      .subscribe()
  }

  private func resetIfNeeded() {
    #if DEBUG
      switch ProcessInfo.processInfo.environment["RESET"] {
      case "all":
        jack.descendant("start").debug("remove all data in UserDefaults database")
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
    let flow = MainFlow(stage: stage)
    return flow.start()
  }
}
