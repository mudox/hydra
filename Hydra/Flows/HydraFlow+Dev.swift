import UIKit

import RxCocoa
import RxSwift

import Then

import SnapKit

import JacKit
import MudoxKit

#if DEBUG

  private let jack = Jack().set(format: .short)

  extension HydraFlow {

    func makeStageController(title: String = "Stage") -> UITabBarController {

      let vc = UIViewController()
      vc.view.backgroundColor = .white
      vc.view.aid = .stageView

      let label = UILabel().then {
        $0.text = title
        $0.font = .systemFont(ofSize: 26)
        $0.textAlignment = .center
        $0.textColor = .darkGray
      }

      vc.view.addSubview(label)
      label.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }

      let tabBarVC = UITabBarController().then {
        $0.viewControllers = [vc]
      }

      return tabBarVC
    }

    func setupUnitTestStage() {
      let vc = makeStageController(title: "Unit Test")
      stage.window.rootViewController = vc
    }

    func setupEarlGreyStage() {
      let tabBarVC = makeStageController(title: "EarlGrey Test")
      stage.window.rootViewController = tabBarVC
    }

    func tryLoginFlow() {
      let stageVC = makeStageController(title: "LoginFlow")
      stage.window.rootViewController = stageVC

      _ = LoginFlow(on: .viewController(stageVC))
        .loginIfNeeded.subscribe(onCompleted: {
          jack.func().info("Login flow completed")
        })
    }

    func tryLanguagesFlow() {
      let stageVC = makeStageController(title: "LanguagesFlow")
      stage.window.rootViewController = stageVC

      _ = LanguagesFlow(on: .viewController(stageVC))
        .selectedLanguage
        .subscribe(onSuccess: { language in
          jack.func().info("""
          LanguagesFlow completed with selected language: \(language ?? "<nil>")
          """)
        })
    }

    func tryLoadingStateView() {
      let stageVC = makeStageController(title: "")
      stage.window.rootViewController = stageVC

      let views = [LoadingStateView(), LoadingStateView(), LoadingStateView(), LoadingStateView()]
      let stackView = UIStackView(arrangedSubviews: views).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .center
      }

      stageVC.view.addSubview(stackView)
      stackView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }

      views[0].showLoading(phase: "Testing LoadingStateView")
      views[1].showEmpty(title: "Found no match")
      views[2].showError(title: "Network is not available", buttonTitle: "Retry")

      _ = Observable<Int>
        .timer(0, period: 0.1, scheduler: MainScheduler.instance)
        .subscribe(onNext: { tick in
          let progress = Double(tick % 101) / 100
          views[3].showProgress(phase: "Downloading", progress: progress)
        })
    }

  }

#endif
