import RxCocoa
import RxSwift

import Cache
import SwiftyUserDefaults

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

private extension String {
  static let allLanguagesCacheKey = "allLanguages"
  static let allLanguagesDiskCacheName = "AllGitHubLanguages"
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
      jack.function().error("Failed to initialize `Cache.Stoarge` instance with error: \(error)")
      return nil
    }
  }()

  private var allLanguagesFromCache: Single<[GitHub.Language]> {
    guard let cache = cache else {
      return .error(Error.nilCache)
    }

    do {
      let languages = try cache.object(forKey: .allLanguagesCacheKey)
      return .just(languages)
    } catch {
      jack.function().warn("Error fetching all languages data from cache: \(error)")
      return .error(error)
    }
  }

  private var allLanguagesFromNetwork: Single<[GitHub.Language]> {
    jack.function().debug("Begin fetching all languages data from network")
    
    return GitHub.Language.all
      .do(onSuccess: { [weak self] languages in
        let log = jack.function().descendant("do(onSuccess:)")
        guard let self = self else {
          log.error("`self` is nil, languages data is not cached")
          return
        }
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
      allLanguagesFromNetwork.asObservable(),
    ]).asSingle()
  }

  // MARK: - Language Groups

  let fixedItems = ["All Languages", "Unknown Languages"]

  var searchedLanguages: Set<String> {
    get {
      return Set(Defaults[.searchedLanguages])
    }
    set {
      Defaults[.searchedLanguages] = Array(newValue)
    }
  }

  static let defaultPinnedLanguages: Set<String> = [
    "Swift", "Objective-C", "JavaScript", "Python", "Shell",
    "Vim Script", "Ruby", "C", "Rust",
  ]

  var pinnedLanguages: Set<String> {
    get {
      return Set(Defaults[.pinnedLanguages])
    }
    set {
      Defaults[.pinnedLanguages] = Array(newValue)
    }
  }

  // MARK: - Search Languages

  struct Matched {
    let history: Set<String>
    let pinned: Set<String>
    let other: Set<String>
  }

  enum SearchState {
    case searching
    case failure(Error)
    case success(Matched)
  }

  let searchTextRelay = BehaviorRelay<String>(value: "")

  var searchResult: Driver<SearchState>!

  // MARK: - Binding

  init() {

    let allLanguages = GitHub.Language.all
      .asObservable()
      .map { languages in
        Set(languages.map { $0.name })
      }
      .share(replay: 1)

    searchResult = searchTextRelay
      .withLatestFrom(allLanguages, resultSelector: { ($0, $1) })
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map { [weak self] text, all -> SearchState in
        guard let self = self else {
          throw CommonError.weakReference("Languages")
        }

        let history = self.searchedLanguages.filter {
          $0.lowercased().contains(text.lowercased())
        }

        let pinned = self.pinnedLanguages.filter {
          $0.lowercased().contains(text.lowercased())
        }

        let other = all
          .subtracting(history)
          .subtracting(pinned)
          .filter {
            $0.contains(text)
          }

        return .success(Matched(
          history: history, pinned: pinned, other: other
        ))
      }
      .startWith(.searching)
      .asDriver { .just(.failure($0)) }

  }

}
