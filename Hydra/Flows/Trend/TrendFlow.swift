import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import GitHub

protocol TrendFlowType {

  func start(animated: Bool) -> Completable

}

class TrendFlow: BaseFlow, TrendFlowType {

  func start(animated: Bool = true) -> Completable {
    let trendViewController = TrendViewController().then {
      $0.model = TrendViewModel(service: GitHub.Trending())
    }

    show(trendViewController, animated: animated)

    return .never()
  }

}
