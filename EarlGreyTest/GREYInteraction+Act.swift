import XCTest

import Nimble
import Quick

import EarlGrey

extension GREYInteraction {
  
  // MARK: - Click / Press

  @discardableResult
  func tap() -> Self {
    return perform(grey_tap())
  }

  // MARK: - Text

  @discardableResult
  func type(text: String) -> Self {
    return perform(grey_typeText(text))
  }

  @discardableResult
  func clearText() -> Self {
    return perform(grey_clearText())
  }

  @discardableResult
  func replaceText(with text: String) -> Self {
    return perform(grey_replaceText(text))
  }

  // MARK: - Scroll
  
  @discardableResult
  func scroll(_ direction: GREYDirection, by amount: CGFloat) -> Self {
    return perform(grey_scrollInDirection(direction, amount))
  }
  
  @discardableResult
  func scroll(to edge: GREYContentEdge) -> Self {
    return perform(grey_scrollToContentEdge(edge))
  }
  
  @discardableResult
  func fastlySwipe(_ direction: GREYDirection) -> Self {
    return perform(grey_swipeFastInDirection(direction))
  }
  
  @discardableResult
  func slowlySwipe(_ direction: GREYDirection) -> Self {
    return perform(grey_swipeSlowInDirection(direction))
  }
  
}
