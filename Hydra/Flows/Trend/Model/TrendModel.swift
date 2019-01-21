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
  var barSelection: BehaviorRelay<(index: Int, item: String)> { get }
  var languagesFlowResult: BehaviorRelay<LanguagesFlowResult> { get }
}

protocol TrendModelOutput {
  var barState: Driver<(items: [String], index: Int)> { get }
  var collectionViewData: Driver<[Trend.Section]> { get }
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

  let barSelection = BehaviorRelay<(index: Int, item: String)>(
    value: (0, "<Skip This Item>")
  )

  let languagesFlowResult = BehaviorRelay<LanguagesFlowResult>(
    value: .init(selected: nil, pinned: ["<Skip This Item>"])
  )

  // MARK: Output

  // swiftlint:disable:next identifier_name
  let _barState = BehaviorRelay<(items: [String], index: Int)>(
    value: (["Skip This Item"], 0)
  )
  let barState: Driver<(items: [String], index: Int)>

  let collectionViewData: Driver<[Trend.Section]>

  // MARK: Binding

  required override init() {
    barState = _barState.asDriver().jack("barState")

    collectionViewData = barSelection.asDriver()
      .map { Trend(ofLanguage: $0.item).sections }

    super.init()

    // Initial bar state
    let pinned = di.resolve(LanguagesServiceType.self)!.pinned
    var items = ["All", "Unknown"]
    items.insert(contentsOf: pinned, at: 1)
    let initialBarState = (items: items, index: 0)

    languagesFlowResult
      .asDriver()
      .withLatestFrom(barSelection.asDriver().skip(1)) { ($0, $1.item) }
      .map { result, oldItem -> ([String], Int) in
        var items = ["All", "Unknown"]
        items.insert(contentsOf: result.pinned, at: 1)

        if let selected = result.selected {
          if let index = items.firstIndex(of: selected) {
            return (items, index)
          } else {
            items.insert(selected, at: 1)
            return (items, 1)
          }
        } else {
          if let index = items.firstIndex(of: oldItem) {
            return (items, index)
          } else {
            items.insert(oldItem, at: 1)
            return (items, 1)
          }
        }
      }
      .startWith(initialBarState)
      .drive(_barState)
      .disposed(by: bag)

  } // init

}
