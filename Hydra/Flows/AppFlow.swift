import UIKit

import RxCocoa
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

  override var run: Completable {
    let run = Completable.create { _ in

      self.resetIfNeeded()
      self.setupTabBar()

//      _ = self.welcomeIfNeeded
//        .andThen(self.runTrendFlow)
//        .forever()

//      devLanguagesFlow
//        .emit(onNext: {
//          jack.func().info("Selected language: \($0 ?? "cancled")")
//        })
//        .disposed(by: disposeBag)

      _ = self.runTrendFlow.forever()

      return Disposables.create()
    }

    return super.run.andThen(run)
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

  private func setupTabBar() {
    UITabBar.appearance().tintColor = .brand
  }

  private var welcomeIfNeeded: Completable {
    _ = FirstLaunchChecker.shared.check()
    jack.sub("welcomeIfNeeded").warn("not implemented yet")

    return .empty()
  }

  private var loginIfNeeded: Completable {
    let flow = LoginFlow(on: stage, credentialService: CredentialService.shared)
    return flow.loginIfNeeded
  }

  private var runTrendFlow: Completable {
    let tabBarController = UITabBarController()
    stage.window.rootViewController = tabBarController

    // Trend
    let trendFlow = TrendFlow(on: .viewController(tabBarController))
    return trendFlow.run
  }

  // MARK: - Development

  #if DEBUG

    private var devLoginFlow: Completable {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LoginFlow(on: .viewController(vc), credentialService: CredentialService.shared)
      return flow.loginIfNeeded
    }

    private var devLanguagesFlow: Signal<String?> {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LanguagesFlow(on: .viewController(vc))
      return flow.start
    }

  #endif
}
