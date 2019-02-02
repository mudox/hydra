import XCTest

import Nimble
import Quick

import GitHub
import MBProgressHUD
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class LoginEGSpec: QuickSpec {

  override func setUp() {
    continueAfterFailure = false
  }

  func runLoginFlow() {
    let flow = LoginFlow(on: The.controller)
    _ = flow.loginIfNeeded.subscribe()
  }

  override func spec() {

    let dismiss = element(.dismissLogin)
    let username = element(.username)
    let clearUsername = element(.clearUsername)
    let password = element(.password)
    let clearPassword = element(.clearPassword)
    let login = element(.loginButton)

    beforeEach {
      appFlow.reset("credentials")
      self.runLoginFlow()
    }

    it("text input") {
      username.perform(grey_typeText("abcdef"))
      clearUsername.perform(grey_tap())
      username.assert(grey_text(""))

      password.perform(grey_typeText("abcdef"))
      clearPassword.perform(grey_tap())
      username.assert(grey_text(""))

      dismiss.perform(grey_tap())
    }

    it("login with valid inputs") {
      username.perform(grey_typeText("cement_ce@163.com"))
      password.perform(grey_typeText("zheshi1geceshihao"))
      login.perform(grey_tap())

      waitHUDToDismiss()
      waitControllerToDismiss()
    }

    it("login with invalid intputs") {
      username.perform(grey_typeText("username@gmail.com"))
      password.perform(grey_typeText("zheshi1geceshihao"))
      login.perform(grey_tap())

      waitHUDToDismiss()
      dismiss.perform(grey_tap())

      waitControllerToDismiss()
    }

  }
}
