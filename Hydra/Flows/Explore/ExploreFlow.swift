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
      let vc = TopicsController()
      let navVC = UINavigationController(rootViewController: vc)

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(navVC)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create()
    }
  }

}
