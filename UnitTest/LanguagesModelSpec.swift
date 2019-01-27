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
    swinject.autoregister(
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

  // MARK: Search States

  describe("search state") {

    it("emits once initially") {
      let states = output.searchState.elements(in: 0.01)
      expect(states.count) == 1
    }

  }

  // MARK: Internal Selection

  describe("selection") {

    it("emits nil initially") {
      let selections = model.selection.elements(in: 0.01)
      expect(selections) == [nil] as [LanguagesModel.Selection?]
    }

  }

  // MARK: Pin Button State

  describe("pin button state") {

    it("emits hide initially") {
      let pinButtonStates = output.pinButtonState.elements(in: 0.01)
      expect(pinButtonStates.count) == 1

      switch pinButtonStates.first! {
      case .hide:
        break
      case .show:
        fatalError("Should be `.hide`")
      }
    }

    it("emits correct titles when item selected") {
      expect({
        let relay = BehaviorRelay<LanguagesModel.PinButtonState>(value: .hide)
        _ = output.pinButtonState.bind(to: relay)

        let selectPinned = LanguagesModel.Selection(indexPath: .init(item: 0, section: 1), language: "Pinned")
        model.selection.accept(selectPinned)
        guard case LanguagesModel.PinButtonState.show("Unpin") = relay.value else {
          return .failed(reason: "Should be `.show(\"Unpin\") when pinned item is selected")
        }

        let selectHistory = LanguagesModel.Selection(indexPath: .init(item: 0, section: 0), language: "History")
        model.selection.accept(selectHistory)
        guard case LanguagesModel.PinButtonState.show("Pin") = relay.value else {
          return .failed(reason: "Should be `.show(\"Pin\") when hitory item is selected")
        }

        let selectOther = LanguagesModel.Selection(indexPath: .init(item: 0, section: 2), language: "Other")
        model.selection.accept(selectOther)
        guard case LanguagesModel.PinButtonState.show("Pin") = relay.value else {
          return .failed(reason: "Should be `.show(\"Pin\") when other item is selected")
        }

        return .succeeded
      }).to(succeed())
    }
  }

  // MARK: Dismiss Button Title

  describe("dismiss button title") {

    it("emits back initial") {
      let selectButtonTitles = output.dismissButtonTitle.elements(in: 0.01)
      expect(selectButtonTitles) == ["Back"]
    }

  }

  // MARK: Dismiss

  describe("dismiss") {

    it("does not emit initially") {
      let elements = output.dismiss.asObservable().elements(in: 0.01)
      expect(elements).to(beEmpty())
    }

    it("returns current selection state") {
      let relay = BehaviorRelay<LanguagesModel.Selection?>(value: nil)
      _ = model.selection.bind(to: relay)

      input.dismissButtonTap.accept(())
      expect(relay.value).to(beNil())

      let sel = LanguagesModel.Selection(indexPath: .init(item: 0, section: 0), language: "Swift")
      model.selection.accept(sel)
      input.dismissButtonTap.accept(())
      expect(relay.value) == sel
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
