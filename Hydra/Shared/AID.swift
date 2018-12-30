import UIKit

extension UIAccessibilityIdentification {

  var aid: AID? {
    get {
      if let id = accessibilityIdentifier {
        return AID(rawValue: id)
      } else {
        return nil
      }
    }
    set {
      accessibilityIdentifier = newValue?.rawValue
    }
  }

}

enum AID: String {
  case stageView

  case hud

  // LoginFlow
  case dismissLogin

  case username
  case clearUsername

  case password
  case clearPassword

  case loginButton

  // LanguagesFlow

  // TrendFlow

  // ExploreFlow

  // UserFlow

  // RepositoryFlow

  // DeveloperFlow
}
