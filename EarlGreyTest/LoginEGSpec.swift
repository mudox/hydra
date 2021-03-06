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
    let flow = LoginFlow(on: The.rootController)
    _ = flow.loginIfNeeded.subscribe()
  }

  override func spec() {

    let dismissButton = element(.dismissLoginBarButtonItem)
    let usernameField = element(.usernameTextField)
    let clearUsernameButton = element(.clearUsernameButton)
    let passwordField = element(.passwordTextField)
    let clearPasswordButton = element(.clearPasswordButton)
    let loginButton = element(.loginButton)

    beforeEach {
      // Make sure the type is not stubbed
      swinject.autoregister(
        CredentialServiceType.self, initializer: CredentialService.init
      )
      appFlow.reset("credentials")
      self.runLoginFlow()
    }

    it("text input") {
      usernameField.perform(grey_typeText("abcdef"))
      clearUsernameButton.perform(grey_tap())
      usernameField.assert(grey_text(""))

      passwordField.perform(grey_typeText("abcdef"))
      clearPasswordButton.perform(grey_tap())
      usernameField.assert(grey_text(""))

      dismissButton.perform(grey_tap())
    }

    it("login with valid inputs") {
      usernameField.perform(grey_typeText("cement_ce@163.com"))
      passwordField.perform(grey_typeText("zheshi1geceshihao"))
      loginButton.perform(grey_tap())

      waitHUDToDismiss()
      waitControllerToDismiss()
    }

    it("login with invalid intputs") {
      usernameField.perform(grey_typeText("username@gmail.com"))
      passwordField.perform(grey_typeText("zheshi1geceshihao"))
      loginButton.perform(grey_tap())

      waitHUDToDismiss()
      dismissButton.perform(grey_tap())

      waitControllerToDismiss()
    }

  }
}
