import SwiftyUserDefaults

import GitHub

import JacKit

private let jack = Jack("CredentialService").set(format: .short)

class CredentialService: GitHub.CredentialServiceType {

  // MARK: - Singleton

  static let shared = CredentialService()

  private init() {}

  // MARK: - GitHub.CredentialServiceType

  var app: (key: String, secret: String)? = (
    key: "46cfca605f029f4fdb3e",
    secret: "fba5480ff4d87ce83daf3b452da1585ddb5f5857"
  )

  var user: (name: String, password: String)? {
    get {
      if let username = Defaults[.username], let password = Defaults[.password] {
        return (username, password)
      } else {
        jack.sub("user").warn("no username and password")
        return nil
      }
    }
    set {
      Defaults[.username] = newValue?.name
      Defaults[.password] = newValue?.password
    }

  }

  var token: String? {
    get {
      if let token = Defaults[.accessToken] {
        return token
      } else {
        jack.sub("token").warn("no access token")
        return nil
      }
    }
    set {
      Defaults[.accessToken] = newValue
    }
  }

}
