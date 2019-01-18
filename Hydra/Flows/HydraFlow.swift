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
    private func makeStageViewController() -> UIViewController {
      let vc = UIViewController()
      vc.view.backgroundColor = .white
      vc.view.aid = .stageView

      let label = UILabel().then {
        $0.text = "EarlGrey Test"
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
      let vc = makeStageViewController()
      stage.window.rootViewController = vc
    }

    private var tryLoginFlow: Completable {
      let makeFlow = Observable<LoginFlow>.create { observer in
        let vc = self.makeStageViewController()
        let flow = LoginFlow(on: .viewController(vc), credentialService: CredentialService())

        observer.onNext(flow)
        return Disposables.create()
      }

      return makeFlow.flatMap {
        $0.loginIfNeeded.asObservable()
      }
      .asCompletable()
    }

    private var tryLanguagesFlow: Single<String?> {
      let makeFlow = Single<LanguagesFlow>.create { single in
        let vc = self.makeStageViewController()
        let flow = LanguagesFlow(on: .viewController(vc))

        single(.success(flow))
        return Disposables.create()
      }

      return makeFlow.flatMap {
        $0.selectedLanguage
      }
    }

  #endif
}
