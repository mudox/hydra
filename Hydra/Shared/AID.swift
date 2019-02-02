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
  case dismissLoginBarButtonItem

  case usernameTextField
  case clearUsernameButton

  case passwordTextField
  case clearPasswordButton

  case loginButton

  // LanguagesFlow
  case dismissLanguagesBarButtonItem
  case pinLanguageBarButtonItem
  case languagesSearchBar
  case languagesCollectionView

  // TrendFlow

  // ExploreFlow

  // UserFlow

  // RepositoryFlow

  // DeveloperFlow
}
