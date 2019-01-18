import RealmSwift

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum Realms {

  static func realm(forUser username: String) -> Realm? {
    guard let supportDir = The.files.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      jack.func().error("Got nil application support directory url, return nil")
      return nil
    }

    let url = supportDir.appendingPathComponent("\(username)/username.realm")
    let config = Realm.Configuration(fileURL: url)

    do {
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
    guard let username = CredentialService().user?.name else {
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
