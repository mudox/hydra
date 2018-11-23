import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol TrendingFlowType {

  func start(animated: Bool) -> Completable

}

class TrendFlow: BaseFlow, TrendingFlowType {

  func start(animated: Bool = true) -> Completable {
    return .create { _ in
      let trendViewController = TrendViewController().then {
        $0.model = TrendViewModel(service: GitHub.Trending())
      }

      self.show(trendViewController, animated: animated)

      // never .complete
      return Disposables.create()
    }
  }

}
