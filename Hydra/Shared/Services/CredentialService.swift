import SwiftyUserDefaults

import GitHub

import Valet

import JacKit

private let jack = Jack().set(format: .short)

class CredentialService: GitHub.CredentialServiceType {

  let app = (
    key: "46cfca605f029f4fdb3e",
    secret: "fba5480ff4d87ce83daf3b452da1585ddb5f5857"
  )

  private let userValet = SecureEnclaveValet.valet(
    with: Identifier(nonEmpty: "HydraAccountIsGitHubAccount")!,
    accessControl: .userPresence
  )

  var user: (name: String, password: String)? {
    get {
      if let username = Defaults[.username] {
        switch userValet.string(forKey: username, withPrompt: "User authentication") {
        case let .success(password):
          return (username, password)
        case .itemNotFound:
          jack.func().verbose("No matching password for username '\(username)' in Keychain, return nil")
          return nil
        case .userCancelled:
          jack.func().verbose("User cancelled anthentication, return nil")
          return nil
        }
      } else {
        jack.func().verbose("No username stored in UserDefaults, return nil")
        return nil
      }
    }
    set {
      if let user = newValue {
        Defaults[.username] = user.name
        if !userValet.set(string: user.password, forKey: user.name) {
          jack.func().warn("Failed to save user password into Keychain which is not accessible")
        }
      } else {
        Defaults.remove(.username)
        if !userValet.removeAllObjects() {
          jack.func().warn("Failed to reset user valet, Keychain is not accessible")
        }
      }
    }
  }

  private let tokenValet = Valet.valet(
    with: Identifier(nonEmpty: "HydraAppGitHubToken")!,
    accessibility: .whenUnlockedThisDeviceOnly
  )

  var token: String? {
    get {
      if let user = user {
        return tokenValet.string(forKey: user.name)
      } else {
        return nil
      }
    }
    set {
      if let token = newValue {
        if let user = user {
          if !tokenValet.set(string: token, forKey: user.name) {
            jack.warn("Failed to save access token into Keychain")
          }
        } else {
          jack.warn("No username in UserDefaults, not logged in? Return nil")
        }
      } else {
        if !tokenValet.removeAllObjects() {
          jack.func().warn("Failed to reset token valet, Keychain is not accessible")
        }
      }
    }
  }

  #if DEBUG
    func reset() {
      Defaults.remove(.username)
      userValet.removeAllObjects()
      tokenValet.removeAllObjects()
    }
  #endif

}

#if DEBUG

  class CredentialServiceStub: CredentialServiceType {

    let app = (
      key: "46cfca605f029f4fdb3e",
      secret: "fba5480ff4d87ce83daf3b452da1585ddb5f5857"
    )

    var user: (name: String, password: String)? = (
      name: "cement_ce@163.com",
      password: "zheshi1geceshihao"
    )

    var token: String? = "56500841c0f2ae21d06495ba12474bad6a448545"

  }

#endif
