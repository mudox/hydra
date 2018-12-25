import UIKit

import RxCocoa
import RxSwift

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

protocol LanguagesFlowType {

  var selectedLanguage: Signal<String?> { get }

  func complete(with selectedLanguage: String?)

}

class LanguagesFlow: BaseFlow, LanguagesFlowType {

  deinit {
    jack.func().debug("💀 \(type(of: self))", format: .bare)
  }

  var singleClosure: ((SingleEvent<String?>) -> Void)!

  var selectedLanguage: Signal<String?> {
    return Single.create { single in
      self.singleClosure = single

      let model = LanguagesModel(service: LanguageService())
      let vc = LanguagesController()
      vc.model = model

      let nav = UINavigationController(rootViewController: vc)
      self.stage.viewController.present(nav, animated: true)

      return Disposables.create()
    }
    .asSignal {
      jack.func().sub("asDriver").error("Unexpected error: \($0)")
      return .just(nil)
    }
  }

  func complete(with selectedLanguage: String?) {
    singleClosure(.success(selectedLanguage))
  }

}
