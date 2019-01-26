import Foundation

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

extension Environs {
  private static let stubTrendServiceKey = "STUB_TREND_SERVICE"
  static var stubTrendService: Bool {
    get { return boolean(forKey: stubTrendServiceKey) }
    set { set(boolean: newValue, forKey: stubTrendServiceKey) }
  }

  private static let stubLanguagesServiceKey = "STUB_LANGUAGES_SERVICE"
  static var stubLanguagesService: String? {
    get { return string(forKey: stubLanguagesServiceKey) }
    set { set(string: newValue, forKey: stubLanguagesServiceKey) }
  }

  private static let stubCredentialServiceKey = "STUB_CREDENTIAL_SERVICE"
  static var stubCredentialService: Bool {
    get { return boolean(forKey: stubCredentialServiceKey) }
    set { set(boolean: newValue, forKey: stubCredentialServiceKey) }
  }
}
