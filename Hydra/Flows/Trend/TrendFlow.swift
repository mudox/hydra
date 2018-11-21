import UIKit

import RxCocoa
import RxSwift

import MudoxKit

protocol TrendingFlowType {

  func start() -> Completable

}

class TrendFlow: BaseFlow, TrendingFlowType {

  func start() -> Completable {
    return .create { _ in

      let viewController = TrendViewController()

      switch self.stage {
      case let .window(window):
        window.rootViewController = viewController
      case let .viewController(viewController):
        viewController.present(viewController, animated: true)
      }

      // Never complete

      return Disposables.create()
    }
  }

}
