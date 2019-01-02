import RxCocoa
import RxSwift

import Cache

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

protocol TrendServiceType {
  func repositories(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]>
  func developers(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]>
}

private func composeKey(category: Trending.Category, language: String, period: Trending.Period) -> String {
  return "\(period.rawValue)-\(language)-\(category)"
}

class TrendService: TrendServiceType {

  // MARK: Repositories

  private func repositoriesFromCache(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]> {
    return .create { single in
      guard let cache = Caches.trend else {
        single(.error(Errors.error("`Caches.trend` returned nil")))
        return Disposables.create()
      }

      do {
        let key = composeKey(category: .repository, language: language, period: period)
        let repositories = try cache.object(forKey: key)
        single(.success(repositories))
      } catch {
        jack.func().warn("Error fetching all languages from cache: \(error.localizedDescription)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private func repositoriesFromNetwork(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]> {
    return Trending().repositories(of: language, for: period)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .do(onSuccess: { repositories in
        let log = jack.func().sub("do(onSuccess:)")

        do {
          guard let cache = Caches.trend else {
            log.error("`Caches.trend` is nil, trending repositories data is not cached")
            return
          }

          let key = composeKey(category: .repository, language: language, period: period)
          try cache.setObject(repositories, forKey: key)
        } catch {
          log.warn("Error caching trending repositories data: \(error)")
        }
      })
  }

  func repositories(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]> {
    return Observable.catchError([
      repositoriesFromCache(of: language, for: period).asObservable(),
      repositoriesFromNetwork(of: language, for: period).asObservable(),
    ]).asSingle()
  }

  // MARK: - Developers

  private func developersFromCache(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]> {
    return .create { single in
      guard let cache = Caches.trend else {
        single(.error(Errors.error("`Caches.trend` returned nil")))
        return Disposables.create()
      }

      do {
        let key = composeKey(category: .developer, language: language, period: period)
        let repositories = try cache.transformCodable(ofType: [Trending.Developer].self).object(forKey: key)
        single(.success(repositories))
      } catch {
        jack.func().warn("Error fetching all languages from cache:\n\(error.localizedDescription)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private func developersFromNetwork(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]> {
    return Trending().developers(of: language, for: period)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .do(onSuccess: { developers in
        let log = jack.func().sub("do(onSuccess:)")

        do {
          guard let cache = Caches.trend else {
            log.error("`Caches.trend` is nil, trending repositories data is not cached")
            return
          }

          let key = composeKey(category: .developer, language: language, period: period)
          try cache.transformCodable(ofType: [Trending.Developer].self).setObject(developers, forKey: key)
        } catch {
          log.warn("Error caching trending developers data: \(error)")
        }
      })
  }

  func developers(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]> {
    return Observable.catchError([
      developersFromCache(of: language, for: period).asObservable(),
      developersFromNetwork(of: language, for: period).asObservable(),
    ]).asSingle()
  }

}
