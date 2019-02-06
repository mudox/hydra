import UIKit

import RxCocoa
import RxSwift

import Cache
import SwiftyUserDefaults

import Then

import SnapKit

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

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

    override func reset(_ target: String) {
      switch target {

      case "environs":
        jack.func().info("Reset environment overrides")
        Environs.reset()

      case "defaults":
        jack.func().info("Reset user defaults")
        Defaults.removeAll()

      case "caches":
        jack.func().info("Reset caches")
        Caches.reset()

      case "realm":
        jack.func().info("Reset Realm data")
        Realms.reset()

      case "credentials":
        jack.func().info("Reset credentials")
        Defaults.remove(.username)
        CredentialService().reset()

      default:
        jack.func().warn("Unrecognized reset token: \(target)")
      }
    }

    override func run(inDebugMode mode: String) {

      initSwinject()

      switch mode {

      case "unittest":
        setupUnitTestStage()

      case "earlgrey":
        setupEarlGreyStage()

      case "login":
        tryLoginFlow()

      case "languages":
        tryLanguagesFlow()

      case "explore":
        let tabBarVC = UITabBarController()
        self.stage.window.rootViewController = tabBarVC
        _ = runExploreFlow(in: tabBarVC).forever()

      case "view":
        tryPlaceholderView()

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
    jack.sub("welcomeIfNeeded").warn("Not implemented yet")

    return .empty()
  }

  private var loginIfNeeded: Completable {
    let flow = LoginFlow(on: stage)
    return flow.loginIfNeeded
  }

  private var runMainFlow: Completable {
    return .create { _ in

      UINavigationBar.appearance().tintColor = .brand
      UITabBar.appearance().tintColor = .brand

      let tabBarVC = UITabBarController()
      self.stage.window.rootViewController = tabBarVC

      _ = self.runTrendFlow(in: tabBarVC).forever()
      _ = self.runExploreFlow(in: tabBarVC).forever()
      _ = self.runSearchFlow(in: tabBarVC).forever()
      _ = self.runUserFlow(in: tabBarVC).forever()

      return Disposables.create()
    }
  }

  private func runTrendFlow(in tabBarController: UITabBarController) -> Completable {
    let trendFlow = TrendFlow(on: tabBarController)
    return trendFlow.run
  }

  private func runExploreFlow(in tabBarController: UITabBarController) -> Completable {
    let exploreFlow = ExploreFlow(on: tabBarController)
    return exploreFlow.run
  }

  private func runSearchFlow(in tabBarController: UITabBarController) -> Completable {
    let searchFlow = SearchFlow(on: tabBarController)
    return searchFlow.run
  }

  private func runUserFlow(in tabBarController: UITabBarController) -> Completable {
    let userFlow = UserFlow(on: tabBarController)
    return userFlow.run
  }

}
