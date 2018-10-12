import MudoxKit

import RxSwift
import RxCocoa

class LoginFlow {

  enum Error: Swift.Error {
    case cancelled
  }

  let viewController: UIViewController

  init(viewController: UIViewController) {
    self.viewController = viewController
  }

  func start() -> Completable {
    let loginViewController = ViewControllers.create(
      LoginViewController.self,
      storyboard: "Login"
    ) !! "load `LoginViewController` failed"
    
    viewController.present(loginViewController, animated: true, completion: nil)

    return completionRelay.asSingle().asCompletable()
  }

  private let completionRelay = PublishRelay<Void>()
}
