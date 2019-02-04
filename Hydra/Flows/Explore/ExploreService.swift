import RxCocoa
import RxSwift

import Cache

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short).set(level: .debug)

protocol ExploreServiceType {
  var topics: Single<[GitHub.CuratedTopic]> { get }
  var collections: Single<[GitHub.Collection]> { get }
}

private let cacheKey = "exploreLists"

class ExploreService: ExploreServiceType {

  // MARK: Full List

  private var listsFromCache: Single<GitHub.Explore.Lists> {
    return .create { single in
      guard let cache = Caches.explore else {
        single(.error(Errors.error("`Caches.explore` returned nil")))
        return Disposables.create()
      }

      do {
        let lists = try cache.object(forKey: cacheKey)
        single(.success(lists))
      } catch {
        jack.func().verbose("Error fetching explore lists from cache:\n\(error)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private var listsFromNetwork: Single<GitHub.Explore.Lists> {
    return GitHub.Explore.lists
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onSuccess: { lists in
        let log = jack.func().sub("do(onSuccess:)")

        do {
          guard let cache = Caches.explore else {
            log.error("`Caches.explore` is nil, explore lists is not cached")
            return
          }

          try cache.setObject(lists, forKey: cacheKey)
        } catch {
          log.warn("Error caching trending developers data: \(error)")
        }
      })
  }

  var topics: Single<[GitHub.CuratedTopic]> {
    return Observable.catchError([
      listsFromCache.asObservable(),
      listsFromNetwork.asObservable()
    ])
      .mapAt(\GitHub.Explore.Lists.topics)
      .asSingle()
  }

  var collections: Single<[GitHub.Collection]> {
    return Observable.catchError([
      listsFromCache.asObservable(),
      listsFromNetwork.asObservable()
    ])
      .mapAt(\GitHub.Explore.Lists.collections)
      .asSingle()
  }

}
