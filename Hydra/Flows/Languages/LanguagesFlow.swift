import UIKit

import RxCocoa
import RxSwift

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

protocol LanguagesFlowType {
  var run: Single<(selected: String?, pinned: [String])> { get }
}

class LanguagesFlow: Flow, LanguagesFlowType {

  /// Returns nil on cancellation
  var run: Single<(selected: String?, pinned: [String])> {
    return .create { single in
      let model = LanguagesModel(service: LanguagesService())
      let sub = model.result
        .subscribe(onSuccess: { result in
          self.stage.viewController.dismiss(animated: true) {
            single(.success(result))
          }
        })

      let vc = LanguagesController(model: model)
      let nav = UINavigationController(rootViewController: vc)
      self.stage.viewController.present(nav, animated: true)

      return Disposables.create([sub])
    }
  }

}
