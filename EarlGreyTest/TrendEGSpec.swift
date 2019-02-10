import XCTest

import Nimble
import Quick

import GitHub
import iCarousel
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class TrendEGSpec: QuickSpec {

  override func spec() {

    fit("does not smoke") {
      appFlow.reset("caches")
      TrendFlow(in: The.rootTabBarController).run.forever()

      element(withLabel: "TREND").atIndex(0).tap()

//      button(withTitle: "Collections")
//        .isInteractable()
//        .tap()
//
//      button(withTitle: "Topics")
//        .isInteractable()
//        .tap()

//      element(withAID: .TrendContainerScrollView)
//        .fastlySwipe(.up)
//        .fastlySwipe(.down)
//        .scroll(to: .right)
//        .scroll(to: .left)
    }
  }

}

private func waitDataToBeLoaded() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    return true
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}
