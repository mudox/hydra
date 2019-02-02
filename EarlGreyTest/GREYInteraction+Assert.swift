import XCTest

import Nimble
import Quick

import EarlGrey

extension GREYInteraction {

  @discardableResult
  func isVisible() -> Self {
    return assert(grey_sufficientlyVisible())
  }
  
  @discardableResult
  func isNotVisible() -> Self {
    return assert(grey_notVisible())
  }

}
