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

  init(
    on stage: FlowStage,
    credentialService: GitHub.CredentialServiceType
  ) {
    self.credentialService = credentialService
    super.init(on: stage)
  }

  // MARK: - LoginFlowType

  var completableClosure: ((CompletableEvent) -> Void)!

  var loginIfNeeded: Completable {

    return .create { completable in
      let clean = Disposables.create {}

      guard !self.credentialService.isAuthorized else {
        completable(.completed)
        return clean
      }

      let LoginController = LoginController().then {
        let credSrv = CredentialService.shared
        let ghSrv = GitHub.Service(credentialService: credSrv)
        let loginSrv = LoginService(githubService: ghSrv)
        let model = LoginModel(flow: self, loginService: loginSrv)
        $0.model = model
      }

      self.completableClosure = completable
      self.stage.viewController.present(LoginController, animated: true)

      return clean
    }
  }

  func complete() {
    stage.viewController.dismiss(animated: true) {
      self.completableClosure(.completed)
    }
  }

}
