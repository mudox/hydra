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
  var barState: BehaviorRelay<(items: [String], index: Int)> { get }
  var collectionViewData: BehaviorRelay<[Trend.Section]> { get }
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

  let barSelection: BehaviorRelay<(index: Int, item: String)>

  let languagesFlowResult: BehaviorRelay<LanguagesFlowResult>

  // MARK: Output

  // swiftlint:disable:next identifier_name
  let barState: BehaviorRelay<(items: [String], index: Int)>
  let collectionViewData: BehaviorRelay<[Trend.Section]>

  // MARK: Binding

  required override init() {
    barSelection = .init(value: (0, "<SKIP>"))
    languagesFlowResult = .init(value: .init(selected: nil, pinned: ["<SKIP>"]))

    barState = .init(value: initialBarState)
    collectionViewData = .init(value: Trend(ofLanguage: "All").sections)

    super.init()

    barSelection
      .map { Trend(ofLanguage: $0.item).sections }
      .bind(to: collectionViewData)
      .disposed(by: bag)

    // Initial bar state

    languagesFlowResult
      .withLatestFrom(barSelection.skip(1)) { ($0, $1.item) }
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
      .bind(to: barState)
      .disposed(by: bag)

  } // init

}

// MARK: - Helpers

private let initialBarState: (items: [String], index: Int) = {
  let pinned = di.resolve(LanguagesServiceType.self)!.pinned
  var items = ["All", "Unknown"]
  items.insert(contentsOf: pinned, at: 1)
  return (items, 0)
}()
