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

  @discardableResult
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

      UINavigationBar.appearance().tintColor = .brand
      UITabBar.appearance().tintColor = .brand

      switch mode {

      case "unittest":
        setupUnitTestStage()

      case "earlgrey":
        setupEarlGreyStage()

      case "login":
        tryLoginFlow()

      case "languages":
        tryLanguagesFlow()

      case "trend":
        let tabBarVC = makeStageController(title: "TrendFlow")
        stage.window.rootViewController = tabBarVC
        TrendFlow(in: tabBarVC).run.forever()

      case "explore":
        let tabBarVC = makeStageController(title: "ExploreFlow")
        stage.window.rootViewController = tabBarVC
        ExploreFlow(in: tabBarVC).run.forever()

      case "search":
        let tabBarVC = makeStageController(title: "SearchFlow")
        stage.window.rootViewController = tabBarVC
        SearchFlow(in: tabBarVC).run.forever()

      case "view":
        tryLoadingStateView()

      case "release":
        welcomeIfNeeded
          .andThen(runMainFlow)
          .forever()

      default:
        jack.failure("Unrecognized run mode: \(mode)")
      }
    }

  #endif

  override func runInReleaseMode() {
    welcomeIfNeeded
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

      TrendFlow(in: tabBarVC).run.forever()
      ExploreFlow(in: tabBarVC).run.forever()
      SearchFlow(in: tabBarVC).run.forever()
      ProfileFlow(in: tabBarVC).run.forever()

      return Disposables.create()
    }
  }

}
