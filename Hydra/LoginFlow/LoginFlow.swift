import MudoxKit

import RxCocoa
import RxSwift

import GitHub

protocol LoginFlowType {

  func loginIfNeeded() -> Completable

  func complete()

}

class LoginFlow: LoginFlowType {

  private let credentialService: GitHub.CredentialServiceType

  private let window: UIWindow?
  private let viewController: UIViewController?

  let completionSignal = PublishSubject<Never>()

  init(
    credentialService: GitHub.CredentialServiceType,
    window: UIWindow? = nil,
    viewController: UIViewController? = nil
  ) {
    self.credentialService = credentialService
    self.window = window
    self.viewController = viewController
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
    ) !! "load `LoginViewController` failed"

    loginViewController.flow = self

    /*
     *
     * Step 2 - Show login view controller
     *
     */

    switch (window, viewController) {
    case (let window?, nil):
      window.rootViewController = loginViewController
    case (nil, let viewController?):
      viewController.present(loginViewController, animated: true, completion: nil)
    default:
      fatalError("either `self.window` or `self.viewController` should not be nil")
    }

    return completionSignal.ignoreElements()
  }

  func complete() {
    switch (window, viewController) {
    case (_?, nil):
      completionSignal.onCompleted()
    case (nil, let viewController?):
      viewController.dismiss(animated: true) {
        self.completionSignal.onCompleted()
      }
    default:
      fatalError("either `self.window` or `self.viewController` should not be nil")
    }
  }
}
