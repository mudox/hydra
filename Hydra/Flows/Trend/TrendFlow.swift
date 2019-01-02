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
      let model = TrendModel(service: TrendService())
      let vc = TrendController(model: model)

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(vc)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create()
    }
  }

}
