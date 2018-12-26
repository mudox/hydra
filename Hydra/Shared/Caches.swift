import GitHub

import Cache

import JacKit

private let jack = Jack().set(format: .short)

enum Caches {

  static let languagesDiskCacheName = "AllGitHubLanguagesDiskCache"

  static let languages: Storage<[GitHub.Language]>? = {
    let memoryConfig = MemoryConfig()
    let diskConfig = DiskConfig(name: languagesDiskCacheName)

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

  static func reset() {
    do {
      try languages?.removeAll()
    } catch {
      jack.func().warn("Error reseting caches: \(error)")
    }
  }

}
