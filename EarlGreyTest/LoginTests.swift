import XCTest

import EarlGrey

class LoginTest: XCTestCase {

  let dismiss = EarlGrey.selectElement(with: grey_accessibilityID("dismissLogin"))
  let username = EarlGrey.selectElement(with: grey_accessibilityID("usernameField"))
  let password = EarlGrey.selectElement(with: grey_accessibilityID("passwordField"))

  override func setUp() {
  }

  override func tearDown() {
  }

  func testAll() {
    username.perform(grey_typeText("cement_ce@163.com"))
    password.perform(grey_typeText("zheshi1geceshihao"))
    dismiss.perform(grey_tap())
  }

}
