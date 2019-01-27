import UIKit

import Action
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

protocol LanguagesModelInput {
  var selectTap: PublishRelay<Void> { get }
  var command: PublishRelay<LanguagesModel.Command> { get }

  var searchText: BehaviorRelay<String> { get }
  var itemTap: BehaviorRelay<LanguagesModel.Selection?> { get }
}

protocol LanguagesModelOutput {
  var selection: BehaviorRelay<LanguagesModel.Selection?> { get }

  var selectButtonTitle: BehaviorRelay<String> { get }

  var isPinButtonEnabled: BehaviorRelay<Bool> { get }
  var pinButtonTitle: PublishRelay<String> { get }

  var loadingState: BehaviorRelay<LoadingState<LanguagesService.SearchResult>> { get }
  var collectionViewData: PublishRelay<LanguagesService.SearchResult> { get }

  var result: Single<String?> { get }
}

protocol LanguagesModelType: LanguagesModelInput, LanguagesModelOutput {}

extension LanguagesModelType {
  var input: LanguagesModelInput { return self }
  var output: LanguagesModelOutput { return self }
}

// MARK: - View Model

class LanguagesModel: ViewModel, LanguagesModelType {
  // MARK: - Dependencies

  let service: LanguagesServiceType = fx()

  // MARK: Input

  let selectTap: PublishRelay<Void>
  let command: PublishRelay<LanguagesModel.Command>

  let searchText: BehaviorRelay<String>
  let itemTap: BehaviorRelay<LanguagesModel.Selection?>

  // MARK: Output

  let selection: BehaviorRelay<LanguagesModel.Selection?>

  // Select button
  let selectButtonTitle: BehaviorRelay<String>

  // Pin button
  let isPinButtonEnabled: BehaviorRelay<Bool>
  let pinButtonTitle: PublishRelay<String>

  // Content area
  let loadingState: BehaviorRelay<LoadingState<LanguagesService.SearchResult>>
  let collectionViewData: PublishRelay<LanguagesService.SearchResult>

  // Complete
  private let _result: PublishRelay<String?>
  let result: Single<String?>

  // MARK: Binding

  required override init() {
    // Inputs
    selectTap = .init()
    command = .init()

    searchText = .init(value: "")
    itemTap = .init(value: nil)

    // Outputs
    selection = .init(value: nil)

    selectButtonTitle = .init(value: "Back")

    isPinButtonEnabled = .init(value: false)
    pinButtonTitle = .init()

    loadingState = .init(value: .loading)
    collectionViewData = .init()

    _result = .init()
    result = _result.take(1).asSingle()

    super.init()

    setupAction()

    setupLoadingState()
    setupCollectionData()
    setupButtonStates()

    setupSelection()

    setupCompletion()
  }

  func setupSelection() {
    let toggleSelection = itemTap.skip(1)
      .scan(nil) { prev, this -> LanguagesModel.Selection? in
        if prev?.indexPath != this?.indexPath {
          return this
        } else {
          return nil
        }
      }

    let resetSelection: Observable<LanguagesModel.Selection?>
      = collectionViewData.mapTo(nil)

    Observable
      .merge(toggleSelection, resetSelection)
      .bind(to: selection)
      .disposed(by: bag)
  }

  func setupButtonStates() {
    selection
      .map { $0 != nil }
      .bind(to: isPinButtonEnabled)
      .disposed(by: bag)

    selection
      .map { $0?.indexPath.section == 1 ? "Unpin" : "Pin" }
      .bind(to: pinButtonTitle)
      .disposed(by: bag)

    selection
      .map { $0 != nil ? "Select" : "Back" }
      .bind(to: selectButtonTitle)
      .disposed(by: bag)
  }

  func setupCompletion() {
    selectTap
      .withLatestFrom(selection)
      .map { $0?.language }
      .do(onNext: { [service] language in
        // Side effect: update history
        if let language = language {
          service.addSelected(language)
        }
      })
      .bind(to: _result)
      .disposed(by: bag)
  }

  let action = Action<String, LanguagesService.SearchResult> {
    let service: LanguagesServiceType = fx()
    return service.search(text: $0).asObservable()
  }

  func setupAction() {
    // Handle commands
    let commandTick = command.asObservable()
      .do(onNext: { [service] in
        switch $0 {
        case let .pin(language):
          service.addPinned(language)
        case let .unpin(language):
          service.removePinned(language)
        case let .movePinned(from: src, to: dest):
          service.movePinned(from: src, to: dest)
        case .retry:
          break
        }
      })
      .filter { cmd in
        // Moving item do need to trigger a refresh
        switch cmd {
        case .movePinned:
          return false
        default:
          return true
        }
      }
      .mapTo(())
      .startWith(()) // Triggers intial loading

    Observable
      .combineLatest(searchText, commandTick) { text, _ in text }
      .jack("triggerAction")
      .bind(to: action.inputs)
      .disposed(by: bag)
  }

  func setupLoadingState() {
    action.executing
      .filter { $0 == true }
      .mapTo(LoadingState<LanguagesService.SearchResult>.loading)
      .bind(to: loadingState)
      .disposed(by: bag)

    action.errors
      .filter {
        // filter out `.notEnabled` error
        if case ActionError.notEnabled = $0 {
          return false
        } else {
          return true
        }
      }
      .map(LoadingState<LanguagesService.SearchResult>.error)
      .bind(to: loadingState)
      .disposed(by: bag)

    action.elements
      .map(LoadingState<LanguagesService.SearchResult>.value)
      .observeOn(MainScheduler.instance)
      .bind(to: loadingState)
      .disposed(by: bag)
  }

  func setupCollectionData() {
    loadingState
      .filterMap { state in
        if let data = state.value {
          return .map(data)
        } else {
          return .ignore
        }
      }
      .bind(to: collectionViewData)
      .disposed(by: bag)
  }
}

// MARK: - Nested Types

extension LanguagesModel {

  struct Selection: Equatable {
    let indexPath: IndexPath
    let language: String
  }

  enum SearchState {
    case inProgress
    case error
    case empty
    case data(LanguagesService.SearchResult)

    var isInProgress: Bool {
      switch self {
      case .inProgress:
        return true
      default:
        return false
      }
    }
    
    var sectionModels: [[SectionModel<String, String>]]? {
      switch self {
      case let .data(result):
        return .map(result.toSectionModels())
      default:
        return .ignore
      }
    }
  }

  enum Command {
    case retry // Triggered by retry button
    case pin(String)
    case unpin(String)
    case movePinned(from: Int, to: Int) // swiftlint:disable:this identifier_name
  }

}
