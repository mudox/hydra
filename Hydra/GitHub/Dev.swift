struct Dev {
  // MARK: - Private

  private static let username = "cempri@163.com"
  private static let password = "ximeng1983gh"

  static let clientID = "46cfca605f029f4fdb3e"
  static let clientSecret = "fba5480ff4d87ce83daf3b452da1585ddb5f5857"

  private static let accessToken = "638cc481ad4c51f6165579e1bdbecec01f94b143"

  private static let defaultMediaType = "application/vnd.github.v3+json"

  private static func base64Encode(username: String, password: String) -> String {
    let src = "\(username):\(password)"
    let data = src.data(using: .utf8)!
    return data.base64EncodedString()
  }

  // MARK: - Authorization Header Values

  static let mudoxAuth =
    "Basic \(base64Encode(username: username, password: password))"

  static let hydraAuth =
    "Basic \(base64Encode(username: clientID, password: clientSecret))"

  static let tokenAuth = "Token \(accessToken)"

  // MARK: - Common Headers

  static let defaultMudoxAuthHeaders: [String: String] = [
    "Accept": defaultMediaType,
    "Authorization": mudoxAuth,
  ]
  static let defaulHydraAuthHeaders: [String: String] = [
    "Accept": defaultMediaType,
    "Authorization": hydraAuth,
  ]

  static let defaultTokenHeaders: [String: String] = [
    "Accept": defaultMediaType,
    "Authorization": tokenAuth,
  ]
}
