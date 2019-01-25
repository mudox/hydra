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
    fx.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesServiceStub.init
    )

    model = LanguagesModel()
    input = model.input
    output = model.output
  }

  afterEach {
    // Supress warning from `ClassInstanceCounting`
    model = nil
    input = nil
    output = nil
  }

  // MARK: Loading States

  describe("loading state") {

    it("to be loading or value initially") {
      let states = output.state.elements(in: 0.01)
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
      let selections = output.selection.elements(in: 0.01)
      expect(selections.first!).to(beNil())
    }

  }

  // MARK: Pin Button

  describe("pin button") {

    it("has no title initially") {
      let pinButtonTitles = output.pinButtonTitle.elements(in: 0.01)
      expect(pinButtonTitles) == []
    }

    it("disabled intially") {
      let pinButtonEnablings = output.pinButtonEnabled.elements(in: 0.01)
      expect(pinButtonEnablings) == [false]
    }

  }

  // MARK: Select Button

  describe("select button") {

    it("title to be back initially") {
      let selectButtonTitles = output.selectButtonTitle.elements(in: 0.01)
      expect(selectButtonTitles) == ["Back"]
    }

  }

  describe("result") {

    it("does not emit initially") {
      let elements = output.result.asObservable().elements(in: 0.01)
      expect(elements).to(beEmpty())
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

  func elements(ofFirst count: Int) -> [E] {
    return try! asObservable()
      .take(count)
      .toBlocking()
      .toArray()
  }
  
}
