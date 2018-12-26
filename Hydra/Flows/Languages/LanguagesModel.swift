import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift

import SwiftyUserDefaults

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

// MARK: - Interface

protocol LanguagesModelInput {
  var searchTextRelay: BehaviorRelay<String> { get }
  var commandRelay: BehaviorRelay<String> { get }
}

protocol LanguagesModelOutput {
  var states: Driver<LanguagesModel.SearchState> { get }
  var collectionViewData: Driver<[LanguagesModel.Section]> { get }
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
  let commandRelay: BehaviorRelay<String> = BehaviorRelay<String>(value: "")

  // MARK: - Output

  let states: Driver<LanguagesModel.SearchState>
  let collectionViewData: Driver<[LanguagesModel.Section]>

  // MARK: - Binding

  var disposeBag = DisposeBag()

  required init(service: LanguageService) {

    states = searchTextRelay
      .flatMap(service.search)
      .map { LanguagesModel.SearchState.success($0) }
      .startWith(LanguagesModel.SearchState.searching)
      .asDriver { error in
        jack.func().sub("states").sub("asDriver").warn("Received error: \(error)")
        return .just(LanguagesModel.SearchState.error(error))
      }

    collectionViewData = states
      .flatMap { state -> Driver<[LanguagesModel.Section]> in
        if let data = state.collectionViewData {
          return .just(data)
        } else {
          return .empty()
        }
      }
  }

}

// MARK: - Types

extension LanguagesModel {

  enum Command {
    case pin(String)
    case unpin(String)
  }

  enum SearchState {

    case searching
    case success([LanguagesModel.Section])
    case error(Swift.Error)

    var collectionViewData: [LanguagesModel.Section]? {
      if case let LanguagesModel.SearchState.success(sections) = self {
        return sections
      } else {
        return nil
      }
    }
  }

  struct Section: SectionModelType {

    let title: String
    var items: [String]

    init(original: LanguagesModel.Section, items: [String]) {
      self = original
      self.items = items
    }

    init(title: String, items: [String]) {
      self.title = title
      self.items = items
    }

  }
}
