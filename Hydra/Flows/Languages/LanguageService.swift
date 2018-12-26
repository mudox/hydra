import RxCocoa
import RxDataSources
import RxSwift

import Cache
import SwiftyUserDefaults

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

private extension String {
  static let allLanguagesCacheKey = "AllGitHubLanguages"
  static let allLanguagesDiskCacheName = "AllGitHubLanguagesDiskCache"
}

class LanguageService {

  enum Error: Swift.Error {
    case nilCache
  }

  // MARK: - Fetch All Languages

  private var allLanguagesFromCache: Single<[GitHub.Language]> {
    return .create { single in
      let clean = Disposables.create()

      guard let cache = Caches.languages else {
        single(.error(Error.nilCache))
        return clean
      }

      do {
        let languages = try cache.object(forKey: .allLanguagesCacheKey)
        single(.success(languages))
      } catch {
        jack.func().warn("Failed with error:\n\(error.localizedDescription)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private var allLanguagesFromNetwork: Single<[GitHub.Language]> {
    return GitHub.Language.all
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .do(onSuccess: { languages in
        let log = jack.func().sub("do(onSuccess:)")

        do {
          guard let cache = Caches.languages else {
            log.error("`Caches.languages` is nil, languages data is not cached")
            return
          }
          try cache.setObject(languages, forKey: .allLanguagesCacheKey)
        } catch {
          log.error("Error caching languages data: \(error)")
        }
      })
  }

  var allLanguages: Single<[GitHub.Language]> {
    return Observable.catchError([
      allLanguagesFromCache.asObservable(),
      allLanguagesFromNetwork.asObservable()
    ]).asSingle()
  }

  // MARK: - Language Groups

  var searchedLanguages: [String] {
    get {
      return Defaults[.searchedLanguages]
    }
    set {
      Defaults[.searchedLanguages] = newValue
    }
  }

  func add(searchedLanguage language: String) {
    // If already exists, move to queue tail
    if let index = searchedLanguages.firstIndex(of: language) {
      searchedLanguages.remove(at: index)
      searchedLanguages.append(language)
      return
    }

    // Pop first item if queue exceeds limit
    if searchedLanguages.count > 10 {
      searchedLanguages.remove(at: 0)
    }

    searchedLanguages.append(language)
  }

  static let defaultPinnedLanguages: [String] = [
    "Swift", "Objective-C", "Python", "JavaScript",
    "Go", "Vim Script", "Ruby", "Rust"
  ]

  var pinnedLanguages: [String] {
    get {
      return Defaults[.pinnedLanguages]
    }
    set {
      Defaults[.pinnedLanguages] = newValue
    }
  }

  func add(pinnedLanguage language: String) {
    // If already exists, do nothing
    if pinnedLanguages.contains(language) {
      return
    }

    // Pop first item if queue exceeds limit
    if pinnedLanguages.count > 10 {
      pinnedLanguages.remove(at: 0)
    }

    pinnedLanguages.append(language)
  }

  // MARK: - Search Languages

  func search(text: String) -> Single<[LanguagesSection]> {
    return allLanguages
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map { all -> [LanguagesSection] in

        let history: [String]
        let pinned: [String]
        let other: [String]

        if text.isEmpty {

          history = self.searchedLanguages
          pinned = self.pinnedLanguages
          other = all.map { $0.name }.sorted { $0.lowercased() < $1.lowercased() }

        } else {

          history = self.searchedLanguages.filter {
            $0.lowercased().contains(text.lowercased())
          }

          pinned = self.pinnedLanguages.filter {
            $0.lowercased().contains(text.lowercased())
          }

          other = Set(all.map { $0.name })
            .subtracting(history)
            .subtracting(pinned)
            .filter { $0.lowercased().contains(text) }
            .sorted { $0.lowercased() < $1.lowercased() }
        }

        return [
          .init(title: "History", items: history),
          .init(title: "Pinned", items: pinned),
          .init(title: "Languages", items: other)
        ]
      }
  }

}
