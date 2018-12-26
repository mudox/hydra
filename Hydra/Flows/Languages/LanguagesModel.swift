import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift

import SwiftyUserDefaults

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol LanguagesModelInput {
  var command: PublishRelay<LanguagesModel.Command> { get }
  var searchText: BehaviorRelay<String> { get }
  var selectedIndexPath: BehaviorRelay<IndexPath?> { get }
}

protocol LanguagesModelOutput {
  var currentIndexPath: Driver<IndexPath?> { get }

  var selectButtonEnabled: Driver<Bool> { get }

  var pinButtonEnabled: Driver<Bool> { get }
  var pinButtonTitle: Driver<String> { get }

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

  // MARK: Input

  let command = PublishRelay<Command>()
  let searchText = BehaviorRelay<String>(value: "")
  let selectedIndexPath = BehaviorRelay<IndexPath?>(value: nil)

  // MARK: Output

  let currentIndexPath: Driver<IndexPath?>

  let selectButtonEnabled: Driver<Bool>
  let pinButtonEnabled: Driver<Bool>
  let pinButtonTitle: Driver<String>

  let states: Driver<LanguagesModel.SearchState>
  let collectionViewData: Driver<[LanguagesModel.Section]>

  // MARK: Binding

  var disposeBag = DisposeBag()

  required init(service: LanguageService) {

    currentIndexPath = selectedIndexPath
      .scan(nil) { prev, this in
        if prev != this {
          return this
        } else {
          return nil
        }
      }
      .asDriverNoError()
      .startWith(nil)

    let enabled = currentIndexPath.map { $0 != nil }
    selectButtonEnabled = enabled
    pinButtonEnabled = enabled

    pinButtonTitle = currentIndexPath.map { $0?.section == 1 ? "Unpin" : "Pin" }

    let commandTrigger = command.asObservable()
      .do(onNext: {
        switch $0 {
        case let .pin(language):
          service.add(pinnedLanguage: language)
        case let .unpin(language):
          service.remove(pinnedLanguage: language)
        }
      })
      .mapTo(())
      .startWith(())

    states = Observable.combineLatest(searchText, commandTrigger)
      .flatMap { text, _ in service.search(text: text) }
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
