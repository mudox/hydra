import GitHub

import Cache

import JacKit

private let jack = Jack().set(format: .short)

enum Caches {

  static let hour = TimeInterval(60 * 60)
  static let day = hour * 24
  static let week = day * 7

  static let languages: Storage<[GitHub.Language]>? = {
    let expiry = Cache.Expiry.seconds(hour)
    let memoryConfig = MemoryConfig()
    let diskConfig = DiskConfig(name: "languages")

    do {
      return try Storage(
        diskConfig: diskConfig,
        memoryConfig: memoryConfig,
        transformer: TransformerFactory.forCodable(ofType: [GitHub.Language].self)
      )
    } catch {
      jack.func().error("Error initializing `Caches.languages`: \(error)")
      return nil
    }
  }()

  static let trend: Storage<[GitHub.Trending.Repository]>? = {
    let expiry = Cache.Expiry.seconds(hour)

    let memoryConfig = MemoryConfig(expiry: expiry)
    let diskConfig = DiskConfig(name: "trend", expiry: expiry)

    do {
      return try Storage(
        diskConfig: diskConfig,
        memoryConfig: memoryConfig,
        transformer: TransformerFactory.forCodable(ofType: [Trending.Repository].self)
      )
    } catch {
      jack.func().error("Error initializing `Caches.trend`: \(error)")
      return nil
    }
  }()

  static let explore: Storage<GitHub.Explore.Lists>? = {
    let expiry = Cache.Expiry.seconds(hour)

    let memoryConfig = MemoryConfig(expiry: expiry)
    let diskConfig = DiskConfig(name: "explore", expiry: expiry)

    do {
      return try Storage(
        diskConfig: diskConfig,
        memoryConfig: memoryConfig,
        transformer: TransformerFactory.forCodable(ofType: GitHub.Explore.Lists.self)
      )
    } catch {
      jack.func().error("Error initializing `Caches.explore`: \(error)")
      return nil
    }
  }()

  static func reset() {
    do {
      try languages?.removeAll()
      try trend?.removeAll()
      try explore?.removeAll()
    } catch {
      jack.func().warn("Error reseting caches: \(error)")
    }
  }

}
