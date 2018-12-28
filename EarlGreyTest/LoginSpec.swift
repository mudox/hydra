import XCTest

import Nimble
import Quick

import EarlGrey

class LoginSpec: QuickSpec {

  override func spec() {

    let dismiss = EarlGrey.selectElement(with: grey_accessibilityID("dismissLogin"))
    let username = EarlGrey.selectElement(with: grey_accessibilityID("usernameField"))
    let password = EarlGrey.selectElement(with: grey_accessibilityID("passwordField"))

    it("do not smoke") {
      username.perform(grey_typeText("cement_ce@163.com"))
      password.perform(grey_typeText("zheshi1geceshihao"))
      dismiss.perform(grey_tap())
    }

  }
}
