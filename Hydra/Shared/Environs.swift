import Foundation

import JacKit

private let jack = Jack().set(format: .short)

public struct Environs {

  // MARK: Private Back Stores

  private static let env = ProcessInfo.processInfo.environment

  private static var bools: [String: Bool] = [:]
  private static var strings: [String: String] = [:]
  private static var tokens: [String: [String]] = [:]

  // MARK: - Bollean

  public static func boolean(forKey key: String) -> Bool {
    if let boolean = bools[key] {
      return boolean
    } else {
      return env.keys.contains(key)
    }
  }

  public static func set(boolean: Bool, forKey key: String) {
    bools[key] = boolean
  }

  // MARK: - String

  public static func string(forKey key: String) -> String? {
    return strings[key] ?? env[key]
  }

  public static func set(string: String, forKey key: String) {
    strings[key] = string
  }

  // MARK: - Tokens

  /// If present, the source string value is first splitted by whitespace into
  /// tokens, each of which is then lowercased.
  ///
  /// - Parameter key: The key string for the value.
  /// - Returns: The token array (with each lowercased).
  public static func tokens(forKey key: String) -> [String] {
    if let tokens = tokens[key] {
      return tokens
    } else {
      return (env[key] ?? "")
        .split(separator: "\u{20}")
        .map { token in
          String(token).lowercased()
        }
    }
  }

  public static func set(tokens list: [String], forKey key: String) {
    tokens[key] = list.map { $0.lowercased() }
  }

  // MARK: - Reset

  public static func reset() {
    bools.removeAll()
    strings.removeAll()
    tokens.removeAll()
  }
}

extension Environs {

  private static let stubTrendServiceKey = "STUB_TREND_SERVICE"
  static var stubTrendService: Bool {
    get { return boolean(forKey: stubTrendServiceKey) }
    set { bools[stubTrendServiceKey] = newValue }
  }

  private static let stubLanguagesServiceKey = "STUB_LANGUAGESSERVICE_SERVICE"
  static var stubLanguagesService: Bool {
    get { return boolean(forKey: stubLanguagesServiceKey) }
    set { bools[stubLanguagesServiceKey] = newValue }
  }

  private static let stubCredentialServiceKey = "STUB_CREDENTIAL_SERVICE"
  static var stubCredentialService: Bool {
    get { return boolean(forKey: stubCredentialServiceKey) }
    set { bools[stubCredentialServiceKey] = newValue }
  }

}
