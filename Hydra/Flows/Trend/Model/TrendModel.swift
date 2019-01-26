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
  var moreLanguage: BehaviorRelay<String?> { get }
}

protocol TrendModelOutput {
  var barState: BehaviorRelay<(items: [String], index: Int)> { get }
  var collectionViewData: BehaviorRelay<[Trend.Section]> { get }
  static var color: BehaviorRelay<UIColor> { get }
}

protocol TrendModelType: TrendModelInput, TrendModelOutput {}

extension TrendModelType {
  var input: TrendModelInput { return self }
  var output: TrendModelOutput { return self }
}

// MARK: - View Model

class TrendModel: ViewModel, TrendModelType {

  // MARK: Input

  let barSelection: BehaviorRelay<(index: Int, item: String)>
  let moreLanguage: BehaviorRelay<String?>

  // MARK: Output

  let barState: BehaviorRelay<(items: [String], index: Int)>
  let collectionViewData: BehaviorRelay<[Trend.Section]>

  static let color = BehaviorRelay<UIColor>(value: .brand)

  // MARK: Binding

  required override init() {
    // Inputs
    barSelection = .init(value: (index: 0, item: "<SKIP>"))
    moreLanguage = .init(value: "<SKIP>")

    // Outputs
    barState = .init(value: initialBarState)
    collectionViewData = .init(value: Trend(ofLanguage: "All").sections)

    super.init()

    barSelectionDrivesCollectionViewData()
    barSelectionDrivesColor()

    moreLanguageDrivesBarState()
  }

  func barSelectionDrivesCollectionViewData() {
    barSelection
      .map { Trend(ofLanguage: $0.item).sections }
      .bind(to: collectionViewData)
      .disposed(by: bag)
  }

  func barSelectionDrivesColor() {
    let languagesList = fx(LanguagesServiceType.self).all
    barSelection.skip(1)
      .withLatestFrom(languagesList) {
        selection, all -> UIColor in
        let name = selection.item
        for language in all where language.name == name {
          return language.color ?? .brand
        }

        switch name {
        case "All":
          return .brand
        case "Unknown":
          return .darkGray
        default:
          jack.failure("Unexpected language name: \(name)")
          return .brand
        }
      }
      .bind(to: TrendModel.color)
      .disposed(by: bag)
  }

  func moreLanguageDrivesBarState() {
    moreLanguage
      .withLatestFrom(barSelection.skip(1)) { ($0, $1.item) }
      .map { newItem, oldItem -> ([String], Int) in
        var items = ["All", "Unknown"]
        let pinned = fx(LanguagesServiceType.self).pinned
        items.insert(contentsOf: pinned, at: 1)

        if let newItem = newItem {
          if let index = items.firstIndex(of: newItem) {
            return (items, index)
          } else {
            items.insert(newItem, at: 1)
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
  }

}

// MARK: - Helpers

private let initialBarState: (items: [String], index: Int) = {
  let pinned = fx(LanguagesServiceType.self).pinned
  var items = ["All", "Unknown"]
  items.insert(contentsOf: pinned, at: 1)
  return (items, 0)
}()
