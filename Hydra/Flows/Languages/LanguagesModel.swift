import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift

import SwiftyUserDefaults

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum LanguagesState {
  case searching
  case success(LanguageService.SearchResult)
  case error(Swift.Error)

  var sectionModels: [LanguagesSectionModel]? {
    if case let LanguagesState.success(result) = self {
      return LanguagesSectionModel.sections(from: result)
    } else {
      return nil
    }
  }
}

struct LanguagesSectionModel: SectionModelType {

  let title: String

  var items: [String]

  init(original: LanguagesSectionModel, items: [String]) {
    self = original
    self.items = items
  }

  init(title: String, items: [String]) {
    self.title = title
    self.items = items
  }

  static func sections(from searchResult: LanguageService.SearchResult) -> [LanguagesSectionModel] {
    return [
      .init(title: "History", items: searchResult.history),
      .init(title: "Pinned", items: searchResult.pinned),
      .init(title: "All", items: searchResult.other)
    ]
  }

}

// MARK: - Interface

protocol LanguagesModelInput {
  var searchTextRelay: BehaviorRelay<String> { get }
}

protocol LanguagesModelOutput {
  var states: Driver<LanguagesState> { get }
  var collectionViewModels: Driver<[LanguagesSectionModel]> { get }
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

  var searchTextRelay = BehaviorRelay<String>(value: "")

  // MARK: - Output

  var states: Driver<LanguagesState>
  var collectionViewModels: Driver<[LanguagesSectionModel]>

  // MARK: - Binding

  var disposeBag = DisposeBag()

  required init(service: LanguageService) {

    states = searchTextRelay
      .flatMap(service.search)
      .map { LanguagesState.success($0) }
      .startWith(LanguagesState.searching)
      .asDriver { error in
        jack.func().sub("asDriver").error("Received error: \(error)")
        return .just(LanguagesState.error(error))
      }

    collectionViewModels = states
      .map { $0.sectionModels }
      .filterNil()
  }

}
