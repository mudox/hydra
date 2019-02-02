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
    let collectionView = element(withAID: .languagesCollectionView)

    let swiftCellItem = element(withLabel: "Swift")
    let unpinnedCellItem = element(withLabel: "D")

    beforeEach {
      swinject.autoregister(
        CredentialServiceType.self, initializer: CredentialServiceStub.init
      )
      appFlow.reset("realm")
      self.runLanguagesFlow()
    }
    
    it("pin button reacts to selection") {
      waitCollectionViewToAppear()

      // Initally hidden
      pinBarItem.isNotVisible()

      // Show pin when a unpinned item is selected
      unpinnedCellItem
        .using(
          searchAction: grey_scrollInDirection(.down, 500),
          onElementWithMatcher: grey_accessibilityID(AID.languagesCollectionView.rawValue)
        )
        .assert(grey_interactable())
        .tap()
      pinButton.isVisible()

      collectionView.scrollTo(.top)

      // Shows unpin when a pinned item is selected
      swiftCellItem.tap()
      unpinButton.isVisible()

      // Hide when no item is selected
      swiftCellItem.tap()
      pinBarItem.isNotVisible()

      dismissButton.tap()
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
