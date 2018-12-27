import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol TrendFlowType {

  var run: Completable { get }

}

class TrendFlow: BaseFlow, TrendFlowType {

  var run: Completable {
    return .create { _ in
      let vc = TrendController().then {
        $0.model = TrendModel(service: GitHub.Trending())
      }

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(vc)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create()
    }
  }

}
