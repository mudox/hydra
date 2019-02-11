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

    beforeEach {
      self.continueAfterFailure = false
    }

    let languageBar = element(.languagesBarCollectionView)
    let moreButton = element(.languagesBarMoreButton)

    let tableView = element(.trendTableView)

    it("run and switch to the tab item") {
//      appFlow.reset("caches")
      TrendFlow(in: The.rootTabBarController).run.forever()

      element(withLabel: "TREND").atIndex(0).tap()

      languageBar.isVisible()
      tableView.isVisible()
      moreButton.isVisible()
    }

    // MARK: - Languages Bar

    describe("languages bar") {

      it("is scrollable") {
        languageBar
          .fastlySwipe(.left)
          .fastlySwipe(.right)
      }

      it("tap item to change content") {
        element(withLabel: "Swift")
          .using(
            searchAction: grey_scrollInDirection(.right, 200),
            onElementWithMatcher: grey_accessibilityID(
              AID.languagesBarCollectionView.rawValue
            )
          )
          .isInteractable()
          .tap()

        element(withLabel: "Python")
          .using(
            searchAction: grey_scrollInDirection(.right, 200),
            onElementWithMatcher: grey_accessibilityID(
              AID.languagesBarCollectionView.rawValue
            )
          )
          .isInteractable()
          .tap()

        languageBar.scroll(to: .left)
        element(withLabel: "All")
          .isVisible()
          .isInteractable()
          .tap()
      }

      it("tap more show languages controller") {
        moreButton.tap()
        element(.languagesCollectionView).isVisible()
        element(.dismissLanguagesBarButtonItem).tap()
        element(.languagesBarCollectionView).isVisible()
      }
    }

    // MARK: Main Area

    describe("main area") {

      it("is scrollable") {
        tableView.fastlySwipe(.up)
        tableView.fastlySwipe(.down)
      }

      it("sections are scrollable horizontally") {
        element(.todayRepositoryView)
          .fastlySwipe(.left)
          .fastlySwipe(.right)

        tableView
          .fastlySwipe(.up)
          .scroll(to: .bottom)
        element(.monthlyDeveloperView)
          .isInteractable()
          .fastlySwipe(.left)
          .fastlySwipe(.right)
      }
      
    }

  }

}
