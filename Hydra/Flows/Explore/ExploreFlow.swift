import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol ExploreFlowType {
  var run: Completable { get }
}

class ExploreFlow: Flow, ExploreFlowType {

  var run: Completable {
    return .create { _ in // never complete
      let vc = ExploreController()
      let navVC = UINavigationController(rootViewController: vc)

      // Setup tab bar
      navVC.tabBarItem.do {
        $0.image = #imageLiteral(resourceName: "Explore")
        $0.selectedImage = #imageLiteral(resourceName: "Explore Selected")
        $0.title = "EXPLORE"
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
