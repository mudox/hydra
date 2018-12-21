import UIKit

import RxSwift

import JacKit
import MudoxKit

import SwiftyUserDefaults

private let jack = Jack("AppFlow").set(format: .short)

extension PrimitiveSequenceType where TraitType == CompletableTrait, ElementType == Swift.Never {

  func forever() -> Disposable {
    let log = jack.func()
    return subscribe(
      onCompleted: {
        log.error("Should never complete")
      },
      onError: {
        log.error("Should never fail, error: \($0)")
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
//      .forever()

//    _ = startDevFlow.forever()

    _ = loginIfNeeded.subscribe(onCompleted: {
      jack.func().info("Login flow completed")
    })

  }

  /// Reset app states for developing purpose
  ///
  /// Reset according to the value of environment variable `RESET_APP`:
  /// - "all":  reset all app data
  private func resetIfNeeded() {
    #if DEBUG
      switch ProcessInfo.processInfo.environment["RESET_APP"] {
      case "all":
        jack.sub("start").debug("clear data in UserDefaults")
        Defaults.removeAll()
      default:
        break
      }
    #endif
  }

  private var welcomeIfNeeded: Completable {
    _ = FirstLaunchChecker.shared.check()
    jack.sub("welcomeIfNeeded").warn("not implemented yet")

    return .empty()
  }

  private var loginIfNeeded: Completable {
    let vc = UIViewController()
    stage.window.rootViewController = vc
    vc.view.backgroundColor = .blue
    let flow = LoginFlow(on: .viewController(vc), credentialService: CredentialService.shared)
    return flow.loginIfNeeded
  }

  var startMainFlow: Completable {
    let tabBarController = UITabBarController()
    stage.window.rootViewController = tabBarController

    // Trend
    let trendFlow = TrendFlow(on: .viewController(tabBarController))
    return trendFlow.start()
  }

  var startDevFlow: Completable {
    let log = jack.func()

    let stageVC = UIViewController()
    stageVC.view.backgroundColor = .red

    stage.window.rootViewController = stageVC

    let flow = LanguagesFlow(on: .viewController(stageVC))
    _ = flow.start()
      .emit(onNext: {
        log.sub("onNext").info("selection: \($0 ?? "cancelled")")
      })

    return .never()
  }
}
