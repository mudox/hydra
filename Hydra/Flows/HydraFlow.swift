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
        jack.func().warn("Unrecognized reset mode token: \(mode)")
      }
    }

    override func run(inDebugMode mode: String) {

      switch mode {

      case "earlgrey":
        setupEarlGreyStage()

      case "login":
        _ = tryLoginFlow.subscribe()

      case "languages":
        _ = tryLanguagesFlow
          .subscribe(onSuccess: {
            jack.func().info("Selected \($0 ?? "nothing")")
          })

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
    private func stageController(title: String = "Stage") -> UIViewController {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      vc.view.aid = .stageView

      let label = UILabel().then {
        $0.text = title
        $0.font = .systemFont(ofSize: 30)
        $0.textAlignment = .center
        $0.textColor = .darkGray
      }

      vc.view.addSubview(label)
      label.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }

      return vc
    }

    private func setupEarlGreyStage() {
      let vc = stageController(title: "EarlGrey Test")
      stage.window.rootViewController = vc
    }

    private var tryLoginFlow: Completable {
      return .create { [unowned self] completable in
        let stageVC = self.stageController(title: "Try LoginFlow")
        self.stage.window.rootViewController = stageVC

        let sub = LoginFlow(
          on: .viewController(stageVC),
          credentialService: CredentialService()
        )
        .loginIfNeeded.subscribe(onCompleted: {
          jack.func().info("Login flow completed")
        })

        return Disposables.create([sub])
      }
    }

    private var tryLanguagesFlow: Single<LanguagesFlowResult> {
      return .create { single in
        let stageVC = self.stageController(title: "Try LanguagesFlow")
        self.stage.window.rootViewController = stageVC

        let sub = LanguagesFlow(on: .viewController(stageVC))
          .run
          .subscribe(onSuccess: { result in
            jack.func().info("""
            LanguagesFlow completed with:
            - Selected language: \(result.selected ?? "<nil>")
            - Pinned languages: \(result.pinned)
            """)
          })

        return Disposables.create([sub])
      }
    }

  #endif
}
