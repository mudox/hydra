import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift

import SwiftyUserDefaults

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum LanguagesSearchState {

  case searching
  case success([LanguagesSection])
  case error(Swift.Error)

  var collectionViewData: [LanguagesSection]? {
    if case let LanguagesSearchState.success(sections) = self {
      return sections
    } else {
      return nil
    }
  }
}

struct LanguagesSection: SectionModelType {

  let title: String
  var items: [String]

  init(original: LanguagesSection, items: [String]) {
    self = original
    self.items = items
  }

  init(title: String, items: [String]) {
    self.title = title
    self.items = items
  }

}

// MARK: - Interface

protocol LanguagesModelInput {
  var searchTextRelay: BehaviorRelay<String> { get }
}

protocol LanguagesModelOutput {
  var states: Driver<LanguagesSearchState> { get }
  var collectionViewData: Driver<[LanguagesSection]> { get }
}

protocol LanguagesModelType: LanguagesModelInput, LanguagesModelOutput {
  init(service: LanguageService)
}

extension LanguagesModelType {
  var input: LanguagesModelInput { return self }
  var output: LanguagesModelOutput { return self }
}

// MARK: - View Model

class LanguagesModel: LanguagesModelType {

  // MARK: - Input

  let searchTextRelay = BehaviorRelay<String>(value: "")

  // MARK: - Output

  let states: Driver<LanguagesSearchState>
  let collectionViewData: Driver<[LanguagesSection]>

  // MARK: - Binding

  var disposeBag = DisposeBag()

  required init(service: LanguageService) {

    states = searchTextRelay
      .flatMap(service.search)
      .map { LanguagesSearchState.success($0) }
      .startWith(LanguagesSearchState.searching)
      .asDriver { error in
        jack.func().sub("asDriver").error("Received error: \(error)")
        return .just(LanguagesSearchState.error(error))
      }

    collectionViewData = states
      .flatMap { state -> Driver<[LanguagesSection]> in
        if let data = state.collectionViewData {
          return .just(data)
        } else {
          return .empty()
        }
      }
  }

}
