import RxCocoa
import RxSwift

import Cache

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short).set(level: .debug)

protocol ExploreServiceType {
  var loadLists: Observable<GitHub.Explore.ListsLoadingState> { get }

  var topics: Single<[GitHub.CuratedTopic]> { get }
  var collections: Single<[GitHub.Collection]> { get }

  var featuredTopics: Single<[GitHub.CuratedTopic]> { get }
  var featuredCollections: Single<[GitHub.Collection]> { get }
}

private let cacheKey = "exploreLists"

class ExploreService: ExploreServiceType {

  // MARK: Full List

  private var listsFromCache: Single<GitHub.Explore.ListsLoadingState> {
    return .create { single in
      guard let cache = Caches.explore else {
        single(.error(Errors.error("`Caches.explore` returned nil")))
        return Disposables.create()
      }

      do {
        let lists = try cache.object(forKey: cacheKey)
        single(.success(.success(lists)))
      } catch {
        jack.func().verbose("Error fetching explore lists from cache:\n\(error)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private var listsFromNetwork: Observable<GitHub.Explore.ListsLoadingState> {
    return GitHub.Explore.lists
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: { state in
        let log = jack.func().sub("do(onNext:)")

        switch state {
        case let .success(lists):
          do {
            guard let cache = Caches.explore else {
              log.error("`Caches.explore` is nil, explore lists is not cached")
              return
            }

            try cache.setObject(lists, forKey: cacheKey)
          } catch {
            log.warn("Error caching trending developers data: \(error)")
          }
        default:
          break
        }
      })
  }

  var loadLists: Observable<GitHub.Explore.ListsLoadingState> {
    return Observable
      .catchError([
        listsFromCache.asObservable(),
        listsFromNetwork
      ])
  }

  private var lists: Single<GitHub.Explore.Lists> {
    return loadLists
      .flatMap { state -> Observable<GitHub.Explore.Lists> in
        if let lists = state.value {
          return .just(lists)
        } else {
          return .empty()
        }
      }
      .asSingle()
  }

  // MARK: - Topics & Collections

  var topics: Single<[GitHub.CuratedTopic]> {
    return lists.map { $0.topics }
  }

  var collections: Single<[GitHub.Collection]> {
    return lists.map { $0.collections }
  }

  // MARK: - Featured Items

  var featuredTopics: Single<[GitHub.CuratedTopic]> {
    return topics
      .map { topics in
        let shuffled = topics.shuffled()
        return Array(shuffled.prefix(featuredItemsCount))
      }
  }

  var featuredCollections: Single<[GitHub.Collection]> {
    return collections
      .map { collections in
        let shuffled = collections.shuffled()
        return Array(shuffled.prefix(featuredItemsCount))
      }
  }

}

private let featuredItemsCount = 8
