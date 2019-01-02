import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

import GitHub
import JacKit
import MudoxKit

fileprivate let jack = Jack().set(format: .short)

// MARK: Interface

protocol TrendModelInput {
  var language: BehaviorRelay<String> { get }
}

protocol TrendModelOutput {
  var trend: Driver<Trend> { get }
}

protocol TrendModelType: TrendModelInput, TrendModelOutput {
  init(service: TrendServiceType)
}

extension TrendModelType {
  var input: TrendModelInput { return self }
  var output: TrendModelOutput { return self }
}

// MARK: - View Model

class TrendModel: TrendModelType {

  // MARK: Types

  // MARK: Input

  let language = BehaviorRelay<String>(value: "all")

  // MARK: Output
  
  let trend: Driver<Trend>

  // MARK: Binding

  var disposeBag = DisposeBag()

  required init(service: TrendServiceType) {
    trend = language
      .asDriver()
      .map(Trend.init)
  }

}

// MARK: - Types

extension TrendModel {

}
