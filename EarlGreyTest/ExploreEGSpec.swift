import XCTest

import Nimble
import Quick

import GitHub
import iCarousel
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class ExploreEGSpec: QuickSpec {

  override func spec() {

    it("does not smoke") {
      appFlow.reset("caches")
      ExploreFlow(in: The.rootTabBarController).run.forever()
      
      element(withLabel: "EXPLORE").atIndex(0).tap()
      waitCarouselToAppear()

      button(withTitle: "Collections")
        .isInteractable()
        .tap()

      button(withTitle: "Topics")
        .isInteractable()
        .tap()

      element( .exploreContainerScrollView)
        .fastlySwipe(.up)
        .fastlySwipe(.down)
        .scroll(to: .right)
        .scroll(to: .left)
    }
  }

}

private func waitCarouselToAppear() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")

    let navVC = The.rootTabBarController.viewControllers![1] as! UINavigationController
    let vc = navVC.viewControllers.first as! ExploreController
    return vc.carousel.isHidden == false
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}
