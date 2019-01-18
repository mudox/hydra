import UIKit

import RxCocoa
import RxSwift

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

protocol LanguagesFlowType {
  var selectedLanguage: Single<String?> { get }
}

class LanguagesFlow: Flow, LanguagesFlowType {

  /// Returns nil on cancellation
  var selectedLanguage: Single<String?> {
    return .create { single in
      let model = LanguagesModel(service: LanguagesService())
      let sub = model.selectedLanguage
        .subscribe(onSuccess: { language in
          self.stage.viewController.dismiss(animated: true) {
            single(.success(language))
          }
        })

      let vc = LanguagesController(model: model)
      let nav = UINavigationController(rootViewController: vc)
      self.stage.viewController.present(nav, animated: true)

      return Disposables.create([sub])
    }
  }

}
