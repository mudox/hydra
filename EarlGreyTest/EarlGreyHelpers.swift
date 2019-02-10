import XCTest

import Nimble
import Quick

import GitHub

import MBProgressHUD

@testable import MudoxKit

@testable import Hydra

import EarlGrey

var appFlow: AppFlowType {
  return (UIApplication.shared.delegate as! AppDelegate).appFlow
}

// func checkInstanceCounts() {
//  let cond = GREYCondition(name: #function) {
//    print("😈 \(#function) ...")
//    return
//      LoginFlow.count == 0
//    && LoginController.count == 0
//    && LoginModel.count == 0
//  }
//
//  let r = cond.wait(withTimeout: 15, pollInterval: 1)
//  expect(r) == true
// }

func waitHUDToDismiss() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    if let view = The.rootController.presentedViewController?.view {
      return MBProgressHUD(for: view) == nil
    } else {
      return true
    }
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}

func waitControllerToDismiss() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    return The.rootController.presentedViewController == nil
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}
