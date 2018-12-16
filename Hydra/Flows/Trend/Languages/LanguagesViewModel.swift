import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

import SwiftyUserDefaults

import MudoxKit
import JacKit

private let jack = Jack().set(format: .short)

// MARK: - Interface

protocol LanguagesViewModelInput {
  var searchTextRelay: BehaviorRelay<String> { get }
}

protocol LanguagesViewModelOutput {

}

protocol LanguagesViewModelType: LanguagesViewModelInput, LanguagesViewModelOutput {
  init(service: LanguageService)
}

extension LanguagesViewModelType {
  var input: LanguagesViewModelInput { return self }
  var output: LanguagesViewModelOutput { return self }
}

// MARK: - View Model

class LanguagesViewModel {

  // MARK: - Types

  // MARK: - Input

  // MARK: - Output
  
  // MARK: - Internal
  
  static let fixed = ["All Languages", "Unknown Languages"]
  
  static let defaultPinned = [
    "Swift", "Objective-C", "JavaScript", "Python", "Ruby", "Shell",
    "Vim Script", "Ruby", "C", "C++", "Rust", "HTML", "CSS"
  ]
  
  var searched: Set<String> {
    get {
      return Set(Defaults[.searchedLanguages])
    }
    set {
      Defaults[.searchedLanguages] = Array(newValue)
    }
  }
  
  var pinned: Set<String> {
    get {
      return Set(Defaults[.pinnedLanguages])
    }
    set {
      Defaults[.pinnedLanguages] = Array(newValue)
    }
  }

  var allLanguages: Observable<[String]>

  // MARK: - Binding

  var disposeBag = DisposeBag()

  required init() {

  }

}
