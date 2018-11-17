import MudoxKit

import RxCocoa
import RxSwift

import GitHub

import JacKit

private let jack = Jack("Hydra.LoginFlow")

protocol LoginFlowType: FlowType {

  func loginIfNeeded() -> Completable

  func complete()

}

class LoginFlow: BaseFlow, LoginFlowType {

  private let credentialService: GitHub.CredentialServiceType

  let completionSignal = PublishSubject<Never>()

  init(
    stage: FlowStage,
    credentialService: GitHub.CredentialServiceType
  ) {
    self.credentialService = credentialService
    super.init(stage: stage)
  }

  func loginIfNeeded() -> Completable {

    if credentialService.isAuthorized {
      return .empty()
    }

    /*
     *
     * Step 1 - Load & configure login view controller
     *
     */

    let loginViewController = ViewControllers.create(
      LoginViewController.self,
      storyboard: "Login"
    )

    loginViewController.flow = self

    /*
     *
     * Step 2 - Show login view controller
     *
     */

    switch stage {
    case let .window(window):
      window.rootViewController = loginViewController
    case let .viewController(viewController):
      viewController.present(loginViewController, animated: true, completion: nil)
    }

    return completionSignal.ignoreElements()
  }

  func complete() {
    jack.descendant("complete").info("logged in", format: .short)

    switch stage {
    case .window:
      completionSignal.onCompleted()
    case let .viewController(viewController):
      viewController.dismiss(animated: true) {
        self.completionSignal.onCompleted()
      }
    }
  }

}
