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
  case loadingStateView

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
  case languagesBarCollectionView
  case languagesBarMoreButton

  case trendTableView

  case todayRepositoryView
  case weeklyRepositoryView
  case monthlyRepositoryView
  case todayDeveloperView
  case weeklyDeveloperView
  case monthlyDeveloperView

  // ExploreFlow
  case exploreContainerScrollView
  case topicsCollectionView
  case collectionsCollectionView

  // ProfileFlow

  // RepositoryFlow

  // DeveloperFlow
}
