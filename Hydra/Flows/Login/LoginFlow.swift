import MudoxKit

import RxCocoa
import RxSwift

import Then

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

protocol LoginFlowType: FlowType {

  var loginIfNeeded: Completable { get }

  func complete()
}

class LoginFlow: BaseFlow, LoginFlowType {

  private let credentialService: GitHub.CredentialServiceType

  let completeRelay = PublishRelay<Void>()

  init(
    on stage: FlowStage,
    credentialService: GitHub.CredentialServiceType
  ) {
    self.credentialService = credentialService
    super.init(on: stage)
  }

  var loginIfNeeded: Completable {

    return .create { completable in
      let noClean = Disposables.create()

      guard !self.credentialService.isAuthorized else {
        completable(.completed)
        return noClean
      }

      let loginViewController = LoginViewController().then {
        let credSrv = CredentialService.shared
        let ghSrv = GitHub.Service(credentialService: credSrv)
        let loginSrv = LoginService(githubService: ghSrv)
        let model = LoginViewModel(flow: self, loginService: loginSrv)
        $0.model = model
      }

      switch self.stage {
      case let .window(window):
        window.rootViewController = loginViewController
      case let .viewController(viewController):
        viewController.present(loginViewController, animated: true, completion: nil)
      }

      self.completeRelay
        .take(1)
        .subscribe(onNext: {
          completable(.completed)
        })
        .disposed(by: self.disposeBag)

      return noClean
    }
  }

  func complete() {
    switch stage {
    case .window:
      completeRelay.accept(())
    case let .viewController(viewController):
      viewController.dismiss(animated: true) {
        self.completeRelay.accept(())
      }
    }
  }

}
