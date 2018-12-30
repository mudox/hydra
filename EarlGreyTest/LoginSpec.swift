import XCTest

import Nimble
import Quick

import GitHub
import MBProgressHUD
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class LoginSpec: QuickSpec {

  override func spec() {

    let dismiss = element(.dismissLogin)
    let username = element(.username)
    let password = element(.password)
    let login = element(.loginButton)

    beforeEach {
      self.continueAfterFailure = false
      
      let window = UIApplication.shared.keyWindow!
      HydraFlow(on: .window(window)).run(reset: ["defaults", "cache"], mode: "login")
    }

    it("dismiss0") {
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

  cond.wait(withTimeout: 15, pollInterval: 1)
}

private func waitControllerToDismiss() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    return window.rootViewController!.presentedViewController == nil
  }

  cond.wait(withTimeout: 15, pollInterval: 1)
}
