import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol TrendFlowType {
  var run: Completable { get }
}

class TrendFlow: TabBarChildFlow, TrendFlowType {

  var run: Completable {
    return .create { _ in // never complete
      let vc = TrendController()
      let navVC = UINavigationController(rootViewController: vc)

      // Setup tab bar
      navVC.tabBarItem.do {
        $0.image = #imageLiteral(resourceName: "Trend")
        $0.selectedImage = #imageLiteral(resourceName: "Trend Selected.pdf")
        $0.title = "TREND"
      }

      var vcs = self.stage.tabBarController.viewControllers ?? []
      vcs.append(navVC)
      self.stage.tabBarController.setViewControllers(vcs, animated: true)

      return Disposables.create {
        _ = self // retain the flow instance
      }
    }
  }

}
