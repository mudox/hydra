import GitHub

import Cache

import JacKit

private let jack = Jack().set(format: .short)

enum Caches {

  static let languages: Storage<[GitHub.Language]>? = {
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
    let expiry = Cache.Expiry.seconds(60 * 60) // expires in 1 hour

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

  static func reset() {
    do {
      try languages?.removeAll()
      try trend?.removeAll()
    } catch {
      jack.func().warn("Error reseting caches: \(error)")
    }
  }

}
