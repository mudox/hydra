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

    func stageController(title: String = "Stage") -> UIViewController {
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
      let vc = stageController(title: "Unit Test")
      stage.window.rootViewController = vc
    }

    func setupEarlGreyStage() {
      let vc = stageController(title: "EarlGrey Test")
      stage.window.rootViewController = vc
    }

    var tryLoginFlow: Completable {
      return .create { [unowned self] completable in
        let vc = self.stageController(title: "Try LoginFlow")
        self.stage.window.rootViewController = vc

        let sub = LoginFlow(on: .viewController(vc))
          .loginIfNeeded.subscribe(onCompleted: {
            jack.func().info("Login flow completed")
            completable(.completed)
          })

        return Disposables.create([sub])
      }
    }

    var tryLanguagesFlow: Completable {
      return .create { completable in
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
            completable(.completed)
          })

        return Disposables.create([sub])
      }
    }

  }

#endif
