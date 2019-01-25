import XCTest

import Nimble
import Quick

import RxBlocking
import RxNimble
import RxTest

import RxCocoa
import RxSwift
import RxSwiftExt

import GitHub
import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

@testable import Hydra

class LanguagesModelSpec: QuickSpec { override func spec() {

  var model: LanguagesModel!
  var input: LanguagesModelInput!
  var output: LanguagesModelOutput!

  beforeEach {
    di.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesServiceStub.init
    )

    model = LanguagesModel()
    input = model.input
    output = model.output
  }

  // MARK: Loading States

  describe("loading state") {
    
    it("to be loading or value initially") {
      let states = output.state.elements(in: 1)
      expect(states.count) == 1

      switch states.first! {
      case .error:
        assertionFailure()
      case .loading, .value:
        break
      }
    }
    
  }

  // MARK: Selection

  describe("selection") {
    
    it("to be nil initially") {
      let selections = output.selection.elements(in: 1)
      expect(selections.first!).to(beNil())
    }
    
  }

  // MARK: Pin Button

  describe("pin button") {

    it("has no title initially") {
      let pinButtonTitles = output.pinButtonTitle.elements(in: 1)
      expect(pinButtonTitles) == []
    }

    it("disabled intially") {
      let pinButtonEnablings = output.pinButtonEnabled.elements(in: 1)
      expect(pinButtonEnablings) == [false]
    }

  }

  // MARK: Select Button

  describe("select button") {
    
    it("title to be back initially") {
      let selectButtonTitles = output.selectButtonTitle.elements(in: 1)
      expect(selectButtonTitles) == ["Back"]
    }
    
  }

} }

extension ObservableType {

  func elements(in interval: RxTimeInterval) -> [E] {
    let oneSecond = Observable<Int>.timer(interval, scheduler: MainScheduler.instance)
    return try! asObservable()
      .takeUntil(oneSecond)
      .toBlocking()
      .toArray()
  }

}