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

protocol TrendModelType: TrendModelInput, TrendModelOutput
{
  init()
}

extension TrendModelType {
  var input: TrendModelInput { return self }
  var output: TrendModelOutput { return self }
}

// MARK: - View Model

class TrendModel: ViewModel, TrendModelType {

  // MARK: Input

  let moreLanguage = BehaviorRelay<String?>(value: nil)
  let language = BehaviorRelay<String>(value: "all")

  // MARK: Output

  let trend: Driver<Trend>

  private let _barItems = BehaviorRelay<[String]>(value: [])
  let barItems: Driver<[String]>

  // MARK: Binding

  required init(service: TrendServiceType) {
    barItems = _barItems.asDriver()

    trend = language
      .asDriver()
      .map(Trend.init)

    super.init()

    moreLanguage.asDriver()
      .map { selected -> [String] in
        let pinned = LanguagesService().pinned
        return items(selected: selected, pinned: pinned)
      }
      .drive(_barItems)
      .disposed(by: bag)
  }

}

// MARK: - Helpers

private func items(selected: String?, pinned: [String]) -> [String] {
  var items = ["All", "Unknown"]
  items.insert(contentsOf: pinned, at: 1)

  if let selected = selected, !pinned.contains(selected) {
    items.insert(selected, at: 1)
  }
  return items
}
