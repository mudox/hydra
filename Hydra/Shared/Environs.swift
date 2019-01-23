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

  private static let stubLanguagesServiceKey = "STUB_LANGUAGESSERVICE_SERVICE"
  static var stubLanguagesService: Bool {
    get { return boolean(forKey: stubLanguagesServiceKey) }
    set { set(boolean: newValue, forKey: stubLanguagesServiceKey) }
  }

  private static let stubCredentialServiceKey = "STUB_CREDENTIAL_SERVICE"
  static var stubCredentialService: Bool {
    get { return boolean(forKey: stubCredentialServiceKey) }
    set { set(boolean: newValue, forKey: stubCredentialServiceKey) }
  }
}
