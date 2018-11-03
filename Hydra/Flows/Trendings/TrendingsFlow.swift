import UIKit

import RxCocoa
import RxSwift

import MudoxKit

class TrendingsFlow: BaseFlow {

  var viewController: UIViewController!

  func start() -> Completable {
    return .create {  _ in

      self.viewController = ViewControllers.create(storyboard: "Trendings")
      self.stage.window.rootViewController = self.viewController

      return Disposables.create()
    }
  }

}
