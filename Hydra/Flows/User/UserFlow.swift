import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol UserFlowType {
  var run: Completable { get }
}

class UserFlow: Flow, UserFlowType {

  var run: Completable {
    return .create { _ in // never complete
      let vc = UserController()
      let navVC = UINavigationController(rootViewController: vc)

      // Setup tab bar
      navVC.tabBarItem.do {
        $0.image = #imageLiteral(resourceName: "User")
        $0.selectedImage = #imageLiteral(resourceName: "User Selected")
        $0.title = "PROFILE"
      }

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(navVC)
      self.stage.tabBarController.setViewControllers(vcs, animated: false)

      return Disposables.create {
        _ = self
      }
    }
  }

}
