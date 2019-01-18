import RxCocoa
import RxDataSources
import RxSwift

import RealmSwift
import RxRealm

import Cache
import SwiftyUserDefaults

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

private extension String {
  static let allLanguagesCacheKey = "allGitHubLanguagesCacheKey"
}

private enum PrimaryKeys {
  static let pinned = "pinned"
  static let history = "history"
}

class LanguageList: Object {
  @objc dynamic var name = ""
  let list = List<String>()

  override static func primaryKey() -> String? {
    return "name"
  }
}

class LanguagesService {

  // MARK: Access Realm

  func getLanguages(forKey key: String, defaultList: [String] = []) -> [String] {
    guard let realm = Realms.user else {
      return []
    }

    if let list = realm.object(ofType: LanguageList.self, forPrimaryKey: key) {
      return list.list.toArray()
    } else {
      jack.func().debug("No initial pinned language list found, populate with default list")
      do {
        try realm.write {
          realm.add(LanguageList(value: [key, defaultList]))
        }
      } catch {
        jack.func().error("""
        Failed to write default pinned language list into realm.
        Error: \(error)
        """, format: [])
      }
      return defaultList
    }
  }

  func set(languages: [String], forKey key: String) {
    do {
      guard let realm = Realms.user else {
        return
      }

      try realm.write {
        let newList = LanguageList(value: [key, languages])
        realm.add(newList, update: true)
      }
    } catch {
      jack.func().error("""
        Failed to write new pinned language list into user Realm.
        Error: \(error)
        """, format: [])
    }
  }

  // MARK: - All

  private var allFromCache: Single<[GitHub.Language]> {
    return .create { single in
      guard let cache = Caches.languages else {
        single(.error(Errors.error("`Caches.languages` returned nil")))
        return Disposables.create()
      }

      do {
        let languages = try cache.object(forKey: .allLanguagesCacheKey)
        single(.success(languages))
      } catch {
        jack.func().warn("Error fetching all languages from cache:\n\(error.localizedDescription)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private var allFromRepository: Single<[GitHub.Language]> {
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

  var all: Single<[GitHub.Language]> {
    return Observable.catchError([
      allFromCache.asObservable(),
      allFromRepository.asObservable()
    ]).asSingle()
  }

  // MARK: - History

  var history: [String] {
    get {
      return getLanguages(forKey: PrimaryKeys.history)
    }
    set {
      set(languages: newValue, forKey: PrimaryKeys.history)
    }
  }

  func add(selectedLanguage language: String) {
    // If already exists, move to queue tail
    if let index = history.firstIndex(of: language) {
      history.remove(at: index)
      history.append(language)
      return
    }

    // Pop first item if queue exceeds limit
    if history.count > 10 {
      history.remove(at: 0)
    }

    history.append(language)
  }

  // MARK: - Pinned

  var pinned: [String] {
    get {
      return getLanguages(forKey: PrimaryKeys.pinned, defaultList: [
        "Swift", "Objective-C", "Python", "JavaScript",
        "Ruby", "Go", "Rust", "VimScript"
      ])
    }
    set {

    }
  }

  func add(pinnedLanguage language: String) {
    // If already exists, do nothing
    if pinned.contains(language) {
      return
    }

    // Pop first item if queue exceeds limit
    if pinned.count > 10 {
      pinned.remove(at: 0)
    }

    pinned.append(language)
  }

  func remove(pinnedLanguage language: String) {
    if let index = pinned.firstIndex(of: language) {
      pinned.remove(at: index)
    } else {
      jack.func().warn("Can not found language `\(language)` not in pinned language list")
    }
  }

  func movePinnedLanguage(from src: Int, to dest: Int) {
    let range = pinned.indices
    guard range.contains(src) && range.contains(dest) else {
      jack.func().error("Invalid index: <\(src)>, <\(dest)>, available range: \(range)")
      return
    }

    let language = pinned.remove(at: src)
    pinned.insert(language, at: dest)
  }

  // MARK: - Search

  func search(text: String) -> Single<[LanguagesModel.Section]> {
    return all
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .map { all -> [LanguagesModel.Section] in

        let history = self.history.filter {
          if text.isEmpty {
            return true
          } else {
            return $0.lowercased().contains(text.lowercased())
          }
        }

        let pinned = self.pinned.filter {
          if text.isEmpty {
            return true
          } else {
            return $0.lowercased().contains(text.lowercased())
          }
        }

        let other = Set(all.map { $0.name })
          .subtracting(history)
          .subtracting(pinned)
          .filter {
            if text.isEmpty {
              return true
            } else {
              return $0.lowercased().contains(text)
            }
          }
          .sorted { $0.lowercased() < $1.lowercased() }
        return [
          .init(title: "History", items: history),
          .init(title: "Pinned", items: pinned),
          .init(title: "Languages", items: other)
        ]
      }
  }

}
