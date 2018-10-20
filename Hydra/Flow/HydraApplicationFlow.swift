import UIKit

import RxSwift

import JacKit
import MudoxKit

import SwiftyUserDefaults

private let jack = Jack("HydraApplicationFlow").set(options: .short)

class HydraApplicationFlow: ApplicationFlow {

  // MARK: - Override ApplicationFlow

  override func start() {
    super.start()

    #if DEBUG
      switch ProcessInfo.processInfo.environment["CLEAN"] {
      case "all":
        jack.descendant("start").debug("remove all data in UserDefaults database")
        Defaults.removeAll()
      default:
        break
      }
    #endif

    _ = FirstLaunchChecker.shared.check()

    let loginFlow = LoginFlow(credentialService: CredentialService.shared, window: window)
    loginFlow
      .loginIfNeeded()
      .subscribe(
        onCompleted: {
          jack.descendant("login").info("logged in")
        },
        onError: {
          jack.descendant("login").error("failed to login: \($0)")
        }
      )
      .disposed(by: disposeBag)
  }

  // MARK: - Login

  var isLoggedIn: Bool {
    return CredentialService.shared.isAuthorized
  }

}
