import SwiftyUserDefaults

// MARK: - Common Prefixes

private let app = "io.github.com.mudox.Hydra"
private let credentialService = "\(app).CredentialService"
private let launch = "\(app).Launches"

extension DefaultsKeys {

  // MARK: - CredentialService

  static let username = DefaultsKey<String?>("\(credentialService).username", defaultValue: nil)
  static let password = DefaultsKey<String?>("\(credentialService).password", defaultValue: nil)
  static let accessToken = DefaultsKey<String?>("\(credentialService).accessToken", defaultValue: nil)

  // MARK: - Launches

  static let lastLaunchRelease = DefaultsKey<String?>("\(launch).lastLaunchRelease", defaultValue: nil)

}
