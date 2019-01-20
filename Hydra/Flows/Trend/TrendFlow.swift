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
      let model = TrendModel()
      let vc = TrendController(model: model)

      let nav = UINavigationController(rootViewController: vc)

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(nav)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create()
    }
  }

}
