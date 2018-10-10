import SwiftyUserDefaults

// MARK: - Common Prefixes

private let app = "io.github.com.mudox.Hydra"
private let credentialService = "\(app).CredentialService"

extension DefaultsKeys {

  // MARK: - CredentialService

  static let username = DefaultsKey<String?>("\(credentialService).username")
  static let password = DefaultsKey<String?>("\(credentialService).password")
  static let accessToken = DefaultsKey<String?>("\(credentialService).accessToken")

}
