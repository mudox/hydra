import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol SearchFlowType {
  var run: Completable { get }
}

class SearchFlow: Flow, SearchFlowType {

  var run: Completable {
    return .create { _ in // never complete
      let vc = SearchController()
      let navVC = UINavigationController(rootViewController: vc)

      // Setup tab bar
      navVC.tabBarItem.do {
        $0.image = #imageLiteral(resourceName: "Search")
        $0.selectedImage = #imageLiteral(resourceName: "Search Selected")
        $0.title = "SEARCH"
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
