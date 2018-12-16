import SwiftyUserDefaults

// MARK: - Common Prefixes

private let app: String = {
  Bundle.main.bundleIdentifier!
}()

private let credentialService = "\(app).CredentialService"
private let launch = "\(app).Launches"
private let languages = "\(app).Languages"

extension DefaultsKeys {

  // MARK: - CredentialService

  static let username = DefaultsKey<String?>(
    "\(credentialService).username",
    defaultValue: nil
  )

  static let password = DefaultsKey<String?>(
    "\(credentialService).password",
    defaultValue: nil
  )

  static let accessToken = DefaultsKey<String?>(
    "\(credentialService).accessToken",
    defaultValue: nil
  )

  // MARK: - Languages

  static let searchedLanguages = DefaultsKey<[String]>(
    "\(languages).searched",
    defaultValue: []
  )

  static let pinnedLanguages = DefaultsKey<[String]>(
    "\(languages).pinned",
    defaultValue: Array(LanguageService.defaultPinnedLanguages)
  )

}
