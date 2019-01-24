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
    let vc = window.rootViewController!
    let flow = LoginFlow(on: .viewController(vc))
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
      appFlow.reset(mode: "credentials")
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
      checkInstanceCounts()
    }

    it("login with invalid intputs") {
      username.perform(grey_typeText("username@gmail.com"))
      password.perform(grey_typeText("zheshi1geceshihao"))
      login.perform(grey_tap())

      waitHUDToDismiss()
      dismiss.perform(grey_tap())

      waitControllerToDismiss()
      checkInstanceCounts()
    }

  }
}

// MARK: - Helpers

func element(_ id: AID) -> GREYInteraction {
  return EarlGrey.selectElement(with: grey_accessibilityID(id.rawValue))
}

private var window: UIWindow {
  return UIApplication.shared.keyWindow!
}

private var rootViewController: UIViewController {
  return window.rootViewController!
}

private var appFlow: AppFlowType {
  return (UIApplication.shared.delegate as! AppDelegate).appFlow
}

private func checkInstanceCounts() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    return LoginFlow.count == 0
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}

private func waitHUDToDismiss() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    if let view = window.rootViewController?.presentedViewController?.view {
      return MBProgressHUD(for: view) == nil
    } else {
      return true
    }
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}

private func waitControllerToDismiss() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    return rootViewController.presentedViewController == nil
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}
