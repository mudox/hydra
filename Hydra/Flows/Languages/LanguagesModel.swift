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

  // Done button
  var dismissButtonTap: PublishRelay<Void> { get }

  // Pin button
  var pinButtonTap: PublishRelay<Void> { get }

  // Search bar
  var searchText: PublishRelay<String> { get }

  // Content area
  var itemTap: PublishRelay<LanguagesModel.Selection> { get }
  var movePinnedItem: PublishRelay<(from: Int, to: Int)> { get }
  var retryButtonTap: PublishRelay<Void> { get }
  var clearSelection: PublishRelay<Void> { get }
}

protocol LanguagesModelOutput {
  // Done button
  var dismissButtonTitle: BehaviorRelay<String> { get }

  // Pin button
  var pinButtonState: BehaviorRelay<LanguagesModel.PinButtonState> { get }

  // Content area
  var searchState: BehaviorRelay<LanguagesModel.SearchState> { get }
  var selection: BehaviorRelay<LanguagesModel.Selection?> { get }

  // Dismiss
  var dismiss: PublishRelay<String?> { get }
}

protocol LanguagesModelType: LanguagesModelInput, LanguagesModelOutput {}

extension LanguagesModelType {
  var input: LanguagesModelInput { return self }
  var output: LanguagesModelOutput { return self }
}

// MARK: - View Model

class LanguagesModel: ViewModel, LanguagesModelType {

  // MARK: Input

  // Done button
  let dismissButtonTap = PublishRelay<Void>()

  // Pin button
  let pinButtonTap = PublishRelay<Void>()

  // Search bar
  let searchText = PublishRelay<String>()

  // Content area
  let itemTap = PublishRelay<LanguagesModel.Selection>()
  let movePinnedItem = PublishRelay<(from: Int, to: Int)>()
  let retryButtonTap = PublishRelay<Void>()
  let clearSelection = PublishRelay<Void>()

  // MARK: Output

  // Done button
  let dismissButtonTitle: BehaviorRelay<String>

  // Pin button
  let pinButtonState: BehaviorRelay<LanguagesModel.PinButtonState>

  // Content area
  let searchState: BehaviorRelay<LanguagesModel.SearchState>
  let selection: BehaviorRelay<LanguagesModel.Selection?>

  // Dismiss
  let dismiss = PublishRelay<String?>()

  // MARK: Internals

  let command: BehaviorRelay<Command>

  let action: Action<String, LanguagesService.SearchResult>

  // MARK: Binding

  required override init() {
    // Ouputs
    dismissButtonTitle = .init(value: "Back")
    pinButtonState = .init(value: .hide)
    searchState = .init(value: .begin(phase: nil))

    // Internals
    selection = .init(value: nil)
    command = .init(value: .retry)
    action = Action {
      let service: LanguagesServiceType = fx()
      return service.search(text: $0).asObservable()
    }

    super.init()

    buttonsTapAndItemMovingDriveCommand()
    searchTextAndCommandDrivesAction()
    actionDrivesSearchState()
    itemTapReloadingMovingDriveSelection()
    selectionDrivesButtons()
    doneTapAndSelectionDriveDismiss()
  }

  func itemTapReloadingMovingDriveSelection() {
    let userTap = itemTap
      // Unselect if user tap the same item
      .withLatestFrom(selection) { this, prev -> Selection? in
        // Special case: (nil, nil) -> nil
        if prev?.indexPath != this.indexPath {
          return this
        } else {
          return nil
        }
      }

    let resetBeforeReloading = searchState
      .filter { $0.isInProgress }
      .mapTo(nil as Selection?)

    let resetBeforeMovingPinnedItem = clearSelection
      .mapTo(nil as Selection?)

    Observable
      .merge(userTap, resetBeforeReloading, resetBeforeMovingPinnedItem)
      .bind(to: selection)
      .disposed(by: bag)
  }

  func selectionDrivesButtons() {
    selection
      .map { selection -> PinButtonState in
        if let selection = selection {
          if selection.indexPath.section == 1 {
            return .show("Unpin")
          } else {
            return .show("Pin")
          }
        } else {
          return .hide
        }
      }
      .bind(to: pinButtonState)
      .disposed(by: bag)

    selection
      .map { $0 != nil ? "Select" : "Back" }
      .bind(to: dismissButtonTitle)
      .disposed(by: bag)
  }

  func doneTapAndSelectionDriveDismiss() {
    dismissButtonTap
      .withLatestFrom(selection)
      .map { $0?.language }
      // Side effect: update history
      .do(onNext: { language in
        if let language = language {
          let service: LanguagesServiceType = fx()
          service.addSelected(language)
        }
      })
      .bind(to: dismiss)
      .disposed(by: bag)
  }

  func buttonsTapAndItemMovingDriveCommand() {
    pinButtonTap
      .withLatestFrom(selection)
      .filterMap { selection -> FilterMap<Command> in
        if let selection = selection {
          let language = selection.language
          let section = selection.indexPath.section
          if section == 1 {
            return .map(Command.unpin(language))
          } else {
            return .map(Command.pin(language))
          }
        } else {
          jack.func().failure(
            "Internal inconsistency: pin button can be tapped iff `selection` is not nil"
          )
          return .ignore
        }
      }
      .bind(to: command)
      .disposed(by: bag)

    movePinnedItem
      .map { Command.movePinned(from: $0.from, to: $0.to) }
      .bind(to: command)
      .disposed(by: bag)

    retryButtonTap
      .mapTo(Command.retry)
      .bind(to: command)
      .disposed(by: bag)
  }

  func searchTextAndCommandDrivesAction() {
    let reload = command
      // Update backing data first
      .do(onNext: { command in
        let service: LanguagesServiceType = fx()
        switch command {
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

    Observable
      .combineLatest(searchText, reload) { text, _ in text }
      .bind(to: action.inputs)
      .disposed(by: bag)
  }

  func actionDrivesSearchState() {
    // SearchState.inProgress
    action.executing
      .filterMap { isExecuting -> FilterMap<SearchState> in
        if isExecuting {
          return .map(SearchState.begin(phase: nil))
        } else {
          return .ignore
        }
      }
      .bind(to: searchState)
      .disposed(by: bag)

    // SearchState.error
    action.errors
      .filterMap { error -> FilterMap<SearchState> in
        // filter out `.notEnabled` error
        if case ActionError.underlyingError = error {
          return .map(SearchState.error(error))
        } else {
          return .ignore
        }
      }
      .bind(to: searchState)
      .disposed(by: bag)

    action.elements
      .map(SearchState.value)
      .bind(to: searchState)
      .disposed(by: bag)
  }

}

// MARK: - Types

extension LanguagesModel {

  enum PinButtonState: Equatable {
    case hide
    case show(String)

    static func == (lhs: PinButtonState, rhs: PinButtonState) -> Bool {
      switch (lhs, rhs) {
      case (.hide, .hide):
        return true
      case let (.show(title1), .show(title2)):
        return title1 == title2
      default:
        return false
      }
    }

  }

  struct Selection: Equatable {
    let indexPath: IndexPath
    let language: String
  }

  enum Command: Equatable {

    case retry // Triggered by retry button
    case pin(String)
    case unpin(String)
    case movePinned(from: Int, to: Int) // swiftlint:disable:this identifier_name

    var isRetry: Bool {
      switch self {
      case .retry:
        return true
      default:
        return false
      }
    }

    static func == (lhs: Command, rhs: Command) -> Bool {
      switch (lhs, rhs) {
      case (.retry, .retry):
        return true
      case let (.pin(title1), .pin(title2)):
        return title1 == title2
      case let (.unpin(title1), .unpin(title2)):
        return title1 == title2
      case let (.movePinned(from: src1, to: dest1), .movePinned(from: src2, to: dest2)):
        return src1 == src2 && dest1 == dest2
      default:
        return false
      }
    }

  }

}

// MARK: SearchState

extension LanguagesModel {

  typealias SearchState = LoadingState<LanguagesService.SearchResult>

}

extension LoadingState where Value == LanguagesService.SearchResult {

  var sectionModels: [SectionModel<String, String>]? {
    switch self {
    case let .value(result):
      return result.toSectionModels()
    default:
      return nil
    }
  }

}
