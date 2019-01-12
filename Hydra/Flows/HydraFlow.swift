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

class HydraFlow: AppFlow {

  #if DEBUG

    override func reset(mode: String) {
      switch mode {

      case "defaults":
        jack.func().info("Reset UserDefaults (\(mode))")
        Defaults.removeAll()

      case "cache":
        jack.func().info("Reset caches from `Cache` (\(mode))")
        Caches.reset()

      case "realm":
        jack.func().info("Reset Realm data (\(mode)) (Currently not implemented)")

      default:
        jack.func().warn("Unrecognized reset mode token: \(mode)")
      }
    }

    override func run(inDebugMode mode: String) {
      switch mode {

      case "login":
        _ = tryLoginFlow.subscribe()

      case "languages":
        _ = tryLanguagesFlow
          .subscribe(onSuccess: {
            jack.func().info("Selected \($0 ?? "nothing")")
          })

      case "earlgrey":
        setupEarlGreyStage()

      case "release":
        _ = welcomeIfNeeded
          .andThen(runMainFlow)
          .forever()

      default:
        jack.failure("Unrecognized run mode: \(mode)")
      }
    }

  #endif

  override func runInReleaseMode() {
    _ = welcomeIfNeeded
      .andThen(runMainFlow)
      .forever()
  }

  // MARK: - Flows

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

    private func setupEarlGreyStage() {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      vc.view.aid = .stageView
      stage.window.rootViewController = vc
    }

    private var tryLoginFlow: Completable {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LoginFlow(on: .viewController(vc), credentialService: CredentialService.shared)
      return flow.loginIfNeeded
    }

    private var tryLanguagesFlow: Single<String?> {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      stage.window.rootViewController = vc

      let flow = LanguagesFlow(on: .viewController(vc))
      return flow.selectedLanguage
    }

  #endif
}
