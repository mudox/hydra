import UIKit

import RxCocoa
import RxSwift

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

struct LanguagesFlowResult {
  let selected: String?
  let pinned: [String]
}

protocol LanguagesFlowType {
  var run: Single<LanguagesFlowResult> { get }
}

class LanguagesFlow: Flow, LanguagesFlowType {

  /// Returns nil on cancellation
  var run: Single<LanguagesFlowResult> {
    return .create { single in
      let vc = LanguagesController()
      let sub = vc.model.result
        .subscribe(onSuccess: { result in
          self.stage.viewController.dismiss(animated: true) {
            single(.success(result))
          }
        })

      let nav = UINavigationController(rootViewController: vc)
      self.stage.viewController.present(nav, animated: true)

      return Disposables.create([sub])
    }
  }

}
