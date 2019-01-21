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

    override func reset(mode: String) {
      switch mode {

      case "environs":
        jack.func().info("Reset `Envrions`")
        Environs.reset()

      case "defaults":
        jack.func().info("Reset `Defaults`")
        Defaults.removeAll()

      case "cache":
        jack.func().info("Reset `Cache`")
        Caches.reset()

      case "realm":
        jack.func().info("Reset `Realm` data")
        Realms.reset()

      case "credentials":
        jack.func().info("Reset `CredentialService`")
        CredentialService().reset()

      default:
        jack.func().warn("Unrecognized reset token: \(mode)")
      }
    }

    override func run(inDebugMode mode: String) {
      switch mode {

      case "unittest":
        setupUnitTestStage()

      case "earlgrey":
        setupEarlGreyStage()

      case "login":
        _ = tryLoginFlow.subscribe()

      case "languages":
        _ = tryLanguagesFlow

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
    let flow = LoginFlow(on: stage, credentialService: CredentialService())
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
    jack.func().warn("Not been implemented yet")
    return .never()
  }

  private func runSearchFlow(in tabBarController: UITabBarController) -> Completable {
    jack.func().warn("Not been implemented yet")
    return .never()
  }

  private func runUserFlow(in tabBarController: UITabBarController) -> Completable {
    jack.func().warn("Not been implemented yet")
    return .never()
  }

}
