import RealmSwift

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum Realms {

  static func realm(forUser username: String) -> Realm? {
    do {
      let supportDir = try The.files.url(
        for: .applicationSupportDirectory, in: .userDomainMask,
        appropriateFor: nil, create: true
      )
      let url = supportDir.appendingPathComponent("\(username)/user.realm")

      try The.files.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true,
        attributes: nil
      )

      let config = Realm.Configuration(fileURL: url)
      return try Realm(configuration: config)
    } catch {
      jack.func().error("""
      Failed to initialize user `Realm` instance, return nil
      Error: \(error)
      """, format: [])
      return nil
    }
  }

  /// Local `Realm` instance for current user
  static var user: Realm? {
    let service: CredentialServiceType = fx()
    guard let username = service.user?.name else {
      jack.func().failure("Need non-nil username from `CredentialService`, return nil")
      return nil
    }

    return realm(forUser: username)
  }

  static func reset() {
    do {
      try user?.write {
        user?.deleteAll()
      }
    } catch {
      jack.func().error("Error deleting all objects in `Realms.user`: \(error)")
    }
  }
}
