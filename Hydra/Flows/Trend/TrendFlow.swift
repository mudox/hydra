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
    let vc = TrendViewController().then {
      $0.model = TrendViewModel(service: GitHub.Trending())
    }

    var vcs = stage.tabBarController.viewControllers ?? []
    vcs.append(vc)
    stage.tabBarController.setViewControllers(vcs, animated: true)

    return .never()
  }

}
