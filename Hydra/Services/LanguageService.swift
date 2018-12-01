import RxCocoa
import RxSwift

import GitHub

protocol LanguageServiceType {

  var allLanguages: Single<GitHub.Language> { get }

  func color(for language: String) -> UIColor

}

class LanguageService: LanguageServiceType {

  var allLanguages: Single<Language> {
    fatalError("not yet implemented")
  }

  func color(for language: String) -> UIColor {
    fatalError("not yet implemented")
  }

}
