import MudoxKit

import RxCocoa
import RxSwift

import Then

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

protocol LoginFlowType: FlowType {
  var loginIfNeeded: Completable { get }
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

  var loginIfNeeded: Completable {

    return .create { completable in
      guard !self.credentialService.isAuthorized else {
        completable(.completed)
        return Disposables.create()
      }

      let github = GitHub.Service(credentialService: CredentialService.shared)
      let login = LoginService(githubService: github)
      let model = LoginModel(service: login)

      let sub = model.dismiss
        .emit(onNext: {
          self.stage.viewController.dismiss(animated: true) {
            completable(.completed)
          }
        })

      let vc = LoginController(model: model)

      self.stage.viewController.present(vc, animated: true)

      return Disposables.create([sub])
    }
  }

}
