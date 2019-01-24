import MudoxKit

import RxCocoa
import RxSwift

import Then

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

protocol LoginFlowType {
  var loginIfNeeded: Completable { get }
}

class LoginFlow: Flow, LoginFlowType {

  private let credential = di.resolve(CredentialServiceType.self)!

  var loginIfNeeded: Completable {
    return .create { completable in
      guard !self.credential.isAuthorized else {
        jack.func().info("Already logged in, complete")
        completable(.completed)
        return Disposables.create()
      }

      let vc = LoginController()

      let sub = vc.model.complete
        .subscribe(onCompleted: {
          self.stage.viewController.dismiss(animated: true) {
            completable(.completed)
          }
        })

      self.stage.viewController.present(vc, animated: true)

      return Disposables.create([sub])
    }
  }

}
