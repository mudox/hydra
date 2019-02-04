import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol TrendFlowType {
  var run: Completable { get }
}

class TrendFlow: Flow, TrendFlowType {

  var run: Completable {
    return .create { _ in // never complete
      let vc = TrendController()
      let navVC = UINavigationController(rootViewController: vc)

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(navVC)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create()
    }
  }

}
