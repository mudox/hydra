import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol TrendModelInput {

  /// Result from presentation of `LanguagesController`
  ///
  /// Flow:
  /// 1. User tap the 'More ...' button on `LanguagesBar`.
  /// 1. Present `LanguagesController`.
  /// 1. User (searchs and) selects a language item.
  /// 1. `LanguageController` is dismissed with the result.
  var moreLanguage: BehaviorRelay<String?> { get }

  /// Selected language item from language bar. Trending contents
  /// of this language will be loaded.
  var language: BehaviorRelay<String> { get }
}

protocol TrendModelOutput {

  /// Drives the outer vertical collection view.
  var trend: Driver<Trend> { get }

  /// Drives `LanguagesBar.items`.
  var barItems: Driver<[String]> { get }
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
