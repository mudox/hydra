import XCTest

import Nimble
import Quick

import GitHub
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class LanguagesEGSpec: QuickSpec {

  func runLanguagesFlow() {
    let flow = LanguagesFlow(on: The.controller)
    _ = flow.selectedLanguage.subscribe()
  }

  override func spec() {

    let dismissButton = element(withAID: .dismissLanguagesBarButtonItem)

    let pinBarItem = element(withAID: .pinLanguageBarButtonItem)
    let pinButton = button(withTitle: "Pin")
    let unpinButton = button(withTitle: "Unpin")
    
    let backButton = button(withTitle: "Back")
    let selectButton = button(withTitle: "Select")

    let searchBar = element(withAID: .languagesSearchBar)
    
    let placeholderView = element(withAID: .placeholderView)
    let collectionView = element(withAID: .languagesCollectionView)

    let swiftCellItem = element(withLabel: "Swift")
    let unpinnedCellItem = element(withLabel: "D")

    beforeEach {
      swinject.autoregister(
        CredentialServiceType.self, initializer: CredentialServiceStub.init
      )

      appFlow.reset("realm")

      self.runLanguagesFlow()
      waitCollectionViewToAppear()
    }

    afterEach {
      dismissButton.tap()
    }

    it("select item") {
      // Initially no selection
      backButton.isVisible()
      pinBarItem.isNotVisible()

      // Show 'Pin' when a unpinned item is selected
      unpinnedCellItem
        .using(
          searchAction: grey_scrollInDirection(.down, 500),
          onElementWithMatcher: grey_accessibilityID(AID.languagesCollectionView.rawValue)
        )
        .assert(grey_interactable())
        .tap()
      pinButton.isVisible()
      selectButton.isVisible()

      collectionView.scrollTo(.top)

      // Shows unpin when a pinned item is selected
      swiftCellItem.tap()
      unpinButton.isVisible()
      selectButton.isVisible()

      // Hide when no item is selected
      swiftCellItem.tap()
      pinBarItem.isNotVisible()
    }

    it("search languages") {
      // Scroll to unveal search bar
      collectionView.scrollTo(.top)
      searchBar.isVisible()
      
      // Has match
      searchBar.type(text: "VimScript")
      element(ofType: UILabel.self, hasText: "VimScript", visible: true).isVisible()
      pinBarItem.isNotVisible()
      backButton.isVisible()

      // No match
      searchBar.clearText().type(text: "sldkjadkjf")
      collectionView.isNotVisible()
      placeholderView.isVisible()
    }

  }

}

private func waitCollectionViewToAppear() {
  let cond = GREYCondition(name: #function) {
    print("😈 \(#function) ...")
    let navVC = The.controller.presentedViewController as! UINavigationController
    let langVC = navVC.topViewController as! LanguagesController
    return langVC.collectionView.isHidden == false
  }

  let r = cond.wait(withTimeout: 15, pollInterval: 1)
  expect(r) == true
}
