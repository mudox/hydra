import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import RxSwiftExt

import SwiftyUserDefaults

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

// MARK: Interface

typealias LanguageSelection = (indexPath: IndexPath, language: String)

protocol LanguagesModelInput {
  var selectTap: PublishRelay<Void> { get }
  var command: PublishRelay<LanguagesModel.Command> { get }

  var searchText: BehaviorRelay<String> { get }
  var itemTap: BehaviorRelay<LanguageSelection?> { get }
}

protocol LanguagesModelOutput {
  var selection: BehaviorRelay<LanguageSelection?> { get }

  var selectButtonTitle: BehaviorRelay<String> { get }

  var pinButtonEnabled: BehaviorRelay<Bool> { get }
  var pinButtonTitle: BehaviorRelay<String> { get }

  var state: BehaviorRelay<LoadingState<[LanguagesModel.Section]>> { get }
  var collectionViewData: BehaviorRelay<[LanguagesModel.Section]> { get }

  var result: Single<LanguagesFlowResult> { get }
}

protocol LanguagesModelType: LanguagesModelInput, LanguagesModelOutput {
  init(service: LanguagesService)
}

extension LanguagesModelType {
  var input: LanguagesModelInput { return self }
  var output: LanguagesModelOutput { return self }
}

// MARK: - View Model

class LanguagesModel: ViewModel, LanguagesModelType {
  // MARK: Input

  let selectTap: PublishRelay<Void>
  let command: PublishRelay<Command>

  let searchText: BehaviorRelay<String>
  let itemTap: BehaviorRelay<LanguageSelection?>

  // MARK: Output

  let selection: BehaviorRelay<LanguageSelection?>

  let selectButtonTitle: BehaviorRelay<String>

  let pinButtonEnabled: BehaviorRelay<Bool>
  let pinButtonTitle: BehaviorRelay<String>

  let state: BehaviorRelay<LoadingState<[LanguagesModel.Section]>>
  let collectionViewData: BehaviorRelay<[LanguagesModel.Section]>

  let _result: BehaviorRelay<LanguagesFlowResult>
  let result: Single<LanguagesFlowResult>

  // MARK: Binding

  let service: LanguagesService

  required init(service: LanguagesService) {
    self.service = service

    // Inputs
    selectTap = .init()
    command = .init()

    searchText = .init(value: "<SKIP>")
    itemTap = .init(value: nil)

    // Outputs
    selection = .init(value: (.init(item: 0, section: 0), "<SKIP>"))

    selectButtonTitle = .init(value: "<SKIP>")

    pinButtonEnabled = .init(value: false)
    pinButtonTitle = .init(value: "<SKIP>")

    state = .init(value: .loading)
    collectionViewData = .init(value: [])

    _result = .init(value: .init(selected: "<SKIP>", pinned: []))
    result = _result.take(1).asSingle()

    super.init()

    cleanThis()
  }

  func cleanThis() {
    let commandTick = command.asObservable()
      .do(onNext: { [service] in
        switch $0 {
        case let .pin(language):
          service.add(pinnedLanguage: language)
        case let .unpin(language):
          service.remove(pinnedLanguage: language)
        case let .movePinnedLanguage(from: src, to: dest):
          service.movePinnedLanguage(from: src, to: dest)
        }
      })
      .mapTo(())
      .startWith(()) // Triggers intial loading

    Observable.combineLatest(searchText, commandTick)
      .flatMap { [service] text, _ in service.search(text: text) }
      .asLoadingStateDriver()
      .drive(state)
      .disposed(by: bag)

    state
      .filterMap { state in
        if let data = state.value {
          return .map(data)
        } else {
          return .ignore
        }
      }
      .bind(to: collectionViewData)
      .disposed(by: bag)

    let tapSelection = itemTap
      .scan(nil) { prev, this -> LanguageSelection? in
        if prev?.indexPath != this?.indexPath {
          return this
        } else {
          return nil
        }
      }
      .startWith(nil)
    let resetSelection: Observable<LanguageSelection?> = collectionViewData.mapTo(nil)
    let effectiveSelection = Observable.merge(tapSelection, resetSelection)

    effectiveSelection
      .map { $0 != nil }
      .bind(to: pinButtonEnabled)
      .disposed(by: bag)

    effectiveSelection
      .map { $0?.0.section == 1 ? "Unpin" : "Pin" }
      .bind(to: pinButtonTitle)
      .disposed(by: bag)

    effectiveSelection
      .map { $0 != nil ? "Select" : "Back" }
      .bind(to: selectButtonTitle)
      .disposed(by: bag)

    // Complete

    selectTap
      .withLatestFrom(effectiveSelection)
      .map { $0?.language }
      .do(onNext: { [service] language in
        // Side effect: update history
        if let language = language {
          service.add(selectedLanguage: language)
        }
      })
      .map { [service] language -> LanguagesFlowResult in
        LanguagesFlowResult(selected: language, pinned: service.pinned)
      }
      .bind(to: _result)
      .disposed(by: bag)
  }

}

// MARK: - Types

extension LanguagesModel {

  enum Command {
    case pin(String)
    case unpin(String)
    case movePinnedLanguage(from: Int, to: Int) // swiftlint:disable:this identifier_name
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
