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
  return "\(period.rawValue)-\(language.lowercased())-\(category)"
}

class TrendService: TrendServiceType {

  // MARK: Repositories

  private func repositoriesFromCache(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Repository]>
  {
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

  private func repositoriesFromNetwork(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Repository]>
  {
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

  func repositories(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Repository]>
  {
    return Observable.catchError([
      repositoriesFromCache(of: language, for: period).asObservable(),
      repositoriesFromNetwork(of: language, for: period).asObservable()
    ]).asSingle()
  }

  // MARK: Developers

  private func developersFromCache(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Developer]>
  {
    return .create { single in
      guard let cache = Caches.trend else {
        single(.error(Errors.error("`Caches.trend` returned nil")))
        return Disposables.create()
      }

      do {
        let key = composeKey(category: .developer, language: language, period: period)
        let developers = try cache.transformCodable(ofType: [Trending.Developer].self).object(forKey: key)
        single(.success(developers))
      } catch {
        jack.func().warn("Error fetching all languages from cache:\n\(error.localizedDescription)")
        single(.error(error))
      }

      return Disposables.create()
    }
  }

  private func developersFromNetwork(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Developer]>
  {
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

  func developers(
    of language: String,
    for period: Trending.Period
  )
    -> Single<[Trending.Developer]>
  {
    return Observable.catchError([
      developersFromCache(of: language, for: period).asObservable(),
      developersFromNetwork(of: language, for: period).asObservable()
    ]).asSingle()
  }

  // MARK: Record Stub Data

  func recordStubData() {
    // swiftlint:disable force_try
    var key = composeKey(category: .repository, language: "all", period: .pastDay)
    let repositories = try! Caches.trend!.object(forKey: key)

    key = composeKey(category: .developer, language: "all", period: .pastDay)
    let developers = try! Caches.trend!.transformCodable(ofType: [Trending.Developer].self).object(forKey: key)

    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let repoFile = docDir.appendingPathComponent("repo.json")
    let devsFile = docDir.appendingPathComponent("dev.json")

    let reposData = try! JSONEncoder().encode(repositories)
    let devsData = try! JSONEncoder().encode(developers)

    try! reposData.write(to: repoFile)
    try! devsData.write(to: devsFile)

    jack.info("Write stub data under: \(docDir)")
    // swiftlint:enable all
  }

}

// swiftlint:disable force_try
class TrendServiceStub: TrendServiceType {

  func repositories(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]> {
    switch period {
    case .pastDay:
      let jsonFile = Bundle.main.url(forResource: "TrendRepositories", withExtension: "json")!
      let data = try! Data(contentsOf: jsonFile)
      let list = try! JSONDecoder().decode([Trending.Repository].self, from: data)
      return .just(list)
    case .pastWeek:
      return .never() // Loading forever
    case .pastMonth:
      return .error(Trending.Error.isDissecting)
    }
  }

  func developers(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]> {
    switch period {
    case .pastDay:
      let jsonFile = Bundle.main.url(forResource: "TrendDevelopers", withExtension: "json")!
      let data = try! Data(contentsOf: jsonFile)
      let list = try! JSONDecoder().decode([Trending.Developer].self, from: data)
      return .just(list)
    case .pastWeek:
      return .never() // Loading forever
    case .pastMonth:
      return .error(Trending.Error.isDissecting)
    }
  }

}

// swiftlint:enable all
