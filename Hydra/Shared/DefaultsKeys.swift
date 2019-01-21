import SwiftyUserDefaults

// MARK: Common Prefixes

private let app: String = Bundle.main.bundleIdentifier!

private let credentialService = "\(app).CredentialService"

extension DefaultsKeys {

  // MARK: - CredentialService

  static let username = DefaultsKey<String?>(
    "\(credentialService).username",
    defaultValue: nil
  )

}
