import XCTest

import Nimble
import Quick

import EarlGrey

extension GREYInteraction {

  // MARK: - Visibility

  @discardableResult
  func isVisible() -> Self {
    return assert(grey_sufficientlyVisible())
  }

  @discardableResult
  func isNotVisible() -> Self {
    return assert(grey_notVisible())
  }

  // MARK: - Interaction

  @discardableResult
  func isInteractable() -> Self {
    return assert(grey_interactable())
  }

  @discardableResult
  func isEnabled() -> Self {
    return assert(grey_enabled())
  }

  /// UIButton, UILabel, UITextField, UITextView has text title or content
  ///
  /// - Parameter text: title or text
  /// - Returns: GREYInteraction
  @discardableResult
  func has(text: String) -> Self {
    return assert(grey_text(text))
  }

}
