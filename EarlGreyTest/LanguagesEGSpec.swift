import XCTest

import Nimble
import Quick

import GitHub
@testable import MudoxKit

@testable import Hydra

import EarlGrey

class LanguagesEGSpec: QuickSpec {

  override func setUp() {
    continueAfterFailure = false
  }

  func runLanguagesFlow() {
    let flow = LanguagesFlow(on: The.controller)
    _ = flow.selectedLanguage.subscribe()
  }

  override func spec() {
    
    it("shows") {
      
    }

  }

}
