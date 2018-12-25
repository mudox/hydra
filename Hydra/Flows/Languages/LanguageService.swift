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

  let cache: Storage<[GitHub.Language]>? = {
    let memoryConfig = MemoryConfig()
    let diskConfig = DiskConfig(name: .allLanguagesDiskCacheName)

    do {
      return try Storage(
        diskConfig: diskConfig,
        memoryConfig: memoryConfig,
        transformer: TransformerFactory.forCodable(ofType: [GitHub.Language].self)
      )
    } catch {
      jack.func().error("Error initializing `Cache.Stoarge`: \(error)")
      return nil
    }
  }()

  private var allLanguagesFromCache: Single<[GitHub.Language]> {
    return .create { single in
      let clean = Disposables.create()

      guard let cache = self.cache else {
        single(.error(Error.nilCache))
        return clean
      }

      do {
        let languages = try cache.object(forKey: .allLanguagesCacheKey)
        single(.success(languages))
      } catch {
        jack.func().warn("Error fetching all languages data from cache: \(error)")
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
          guard let cache = self.cache else {
            log.error("`self.cache` is nil, languages data is not cached")
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

  let fixedItems = ["All Languages", "Unknown Languages"]

  var searchedLanguages: [String] {
    get {
      return Defaults[.searchedLanguages]
    }
    set {
      Defaults[.searchedLanguages] = newValue
    }
  }

  static let defaultPinnedLanguages: [String] = [
    "Swift", "Objective-C", "JavaScript", "Python", "Shell",
    "Vim Script", "Ruby", "C", "Rust"
  ]

  var pinnedLanguages: [String] {
    get {
      return Defaults[.pinnedLanguages]
    }
    set {
      Defaults[.pinnedLanguages] = newValue
    }
  }

  // MARK: - Search Languages

  func search(text: String) -> Single<[LanguagesSection]> {
    return Observable.just(text)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .withLatestFrom(allLanguages) { ($0, $1) }
      .map { text, all -> [LanguagesSection] in

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
          .init(title: "Search History", items: history),
          .init(title: "Pinned Languages", items: pinned),
          .init(title: "Languages", items: other)
        ]
      }
      .asSingle()
  }

}
