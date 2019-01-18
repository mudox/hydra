import Foundation

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum Files {

  static var appSupportDir: URL? {
    do {
      return try The.files.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask, appropriateFor: nil,
        create: true
      )
    } catch {
      jack.func().error("""
      Failed to find or create the `Application Support` directory, return nil.
      Error: \(error)
      """, format: [])
      return nil
    }
  }

  static var userSupportDir: URL? {
    guard let rootDir = appSupportDir else {
      return nil
    }

    guard let username = CredentialService().user?.name else {
      return nil
    }

    let dir = rootDir.appendingPathComponent(username)
    if !The.files.fileExists(atPath: dir.path) {
      do {
        try The.files.createDirectory(
          at: dir, withIntermediateDirectories: true,
          attributes: nil
        )
      } catch {
        jack.func().error("""
        Failed to create user support directory, return nil.
        Error: \(error)
        """, format: [])
      }
    }

    return dir
  }

}
