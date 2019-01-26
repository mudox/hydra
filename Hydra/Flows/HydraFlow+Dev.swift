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

    func makeStageController(title: String = "Stage") -> UIViewController {
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

    func setupUnitTestStage() {
      let vc = makeStageController(title: "Unit Test")
      stage.window.rootViewController = vc
    }

    func setupEarlGreyStage() {
      let vc = makeStageController(title: "EarlGrey Test")
      stage.window.rootViewController = vc
    }

    func tryLoginFlow() {
      let vc = makeStageController(title: "Try LoginFlow")
      stage.window.rootViewController = vc

      _ = LoginFlow(on: .viewController(vc))
        .loginIfNeeded.subscribe(onCompleted: {
          jack.func().info("Login flow completed")
        })
    }

    func tryLanguagesFlow() {
      let stageVC = makeStageController(title: "Try LanguagesFlow")
      stage.window.rootViewController = stageVC

      _ = LanguagesFlow(on: .viewController(stageVC))
        .selectedLanguage
        .subscribe(onSuccess: { language in
          jack.func().info("""
          LanguagesFlow completed with selected language: \(language ?? "<nil>")
          """)
        })
    }

  }

#endif
