import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

import Cache
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

      #if DEBUG
        switch ProcessInfo.processInfo.environment["HYDRA_RUN_MODE"] {
        case "login"?:
          _ = self.tryLoginFlow.subscribe()
        case "languages"?:
          _ = self.tryLanguagesFlow
            .emit(onNext: {
              jack.func().info("Selected \($0 ?? "nothing")")
            })
        default:
          _ = self.welcomeIfNeeded
            .andThen(self.runMainFlow)
            .forever()
        }
      #else
        _ = self.welcomeIfNeeded
          .andThen(self.runMainFlow)
          .forever()
      #endif

      return Disposables.create()
    }

    return super.run.andThen(run)
  }

  /// Reset app states for developing purpose
  ///
  /// Reset according to the value of environment variable __RESET__:
  /// - "defaults":  reset UserDefaults through SwiftyUserDefaults
  /// - "cache": reset caches through Cache
  private func resetIfNeeded() {
    #if DEBUG
      guard let env = ProcessInfo.processInfo.environment["HYDRA_RESET"] else { return }

      if env.contains("defaults") {
        jack.func().info("Reset UserDefaults")
        Defaults.removeAll()
      }

      if env.contains("cache") {
        jack.func().info("Reset caches")
        Caches.reset()
      }

    #endif
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

  private var runMainFlow: Completable {
    return .create { _ in

      UINavigationBar.appearance().tintColor = .brand
      UITabBar.appearance().tintColor = .brand

      let vc = UITabBarController()
      self.stage.window.rootViewController = vc

      _ = self.runTrendFlow(in: vc).forever()
      _ = self.runExploreFlow(in: vc).forever()
      _ = self.runSearchFlow(in: vc).forever()
      _ = self.runUserFlow(in: vc).forever()

      return Disposables.create()
    }
  }

  private func runTrendFlow(in tabBarController: UITabBarController) -> Completable {
    // Trend
    let trendFlow = TrendFlow(on: .viewController(tabBarController))
    return trendFlow.run
  }

  private func runExploreFlow(in tabBarController: UITabBarController) -> Completable {
    jack.func().warn("Explore flow has not been implemented yet")
    return .never()
  }

  private func runSearchFlow(in tabBarController: UITabBarController) -> Completable {
    jack.func().warn("Search flow has not been implemented yet")
    return .never()
  }

  private func runUserFlow(in tabBarController: UITabBarController) -> Completable {
    jack.func().warn("User flow has not been implemented yet")
    return .never()
  }

  // MARK: - Development

  #if DEBUG

    private var tryLoginFlow: Completable {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LoginFlow(on: .viewController(vc), credentialService: CredentialService.shared)
      return flow.loginIfNeeded
    }

    private var tryLanguagesFlow: Signal<String?> {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LanguagesFlow(on: .viewController(vc))
      return flow.selectedLanguage
    }

  #endif
}
