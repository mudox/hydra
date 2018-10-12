import UIKit

import RxSwift

import JacKit
import MudoxKit

private let jack = Jack("ApplicationFlow")

/// Abstract base class for any concrete application flow.
class ApplicationFlow: BaseFlow {

  override var viewController: UIViewController! {
    get { return window.rootViewController }
    set { window.rootViewController = newValue }
  }

  override var parentFlow: BaseFlow? {
    get {
      return nil
    }
    set {
      if newValue != nil {
        fatalError("application flow should not have any parent flow")
      }
    }
  }

  func transition(to flow: Flow) {
    fatalError("Abstract member, need to be overriden by subclasses")
  }

  func dismiss(_: Flow?) {
    fatalError("Abstract member, need to be overriden by subclasses")
  }

  // MARK: - ApplicationFlow

  let window: UIWindow

  init(window: UIWindow) {
    self.window = window
  }

  func start() {
    fatalError("Abstract member, need to be overriden by subclasses")
  }

}

class HydraApplicationFlow: ApplicationFlow {
  override func start() {
    loadMainFlow()

    if !isLoggedIn {
      login()
    } else {
      jack.descendant("start").debug("already logged in")
    }
  }

  // MARK: - Main Flow

  func loadMainFlow() {

  }

  // MARK: - Login

  var isLoggedIn: Bool {
    return CredentialService.shared.token != nil
  }

  func login() {
    let loginFlow = LoginFlow(viewController: window.rootViewController!)
    loginFlow.start().subscribe().disposed(by: disposeBag)
  }

  // MARK: - Onboarding Screens

  var isFirstLaunchOfTheApp: Bool {
    fatalError("Not yet implemented")
  }

  func isFirstLaunch(of version: String) -> Bool {
    fatalError("Not yet implemented")
  }

}
