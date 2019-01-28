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
  
  let selectHistory = LanguagesModel.Selection(indexPath: .init(item: 0, section: 0), language: "History")
  let selectPinned = LanguagesModel.Selection(indexPath: .init(item: 0, section: 1), language: "Pinned")
  let selectOther = LanguagesModel.Selection(indexPath: .init(item: 0, section: 2), language: "Other")


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
    
    it("start searchoing with inprogress") {
      let states = output.searchState.elements(in: 0.01)
      model.command.accept(.retry)
      
      expect(states.count) == 1
      expect(states.first!.isInProgress).to(beTrue())
    }
    
    fit("emit collection view data on success") {
//      Environs.stubLanguagesService = "value"
//
//      let states = output.searchState.elements(in: 4)
//      model.command.accept(.retry)
//
    }
    
    fit("test elemetns") {
      let relay = PublishRelay<Int>()
      
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
        jack.func().debug("feed 0")
        relay.accept(0)
        jack.func().debug("feed 1")
        relay.accept(1)
      }

      let elements = relay.elements(in: 2)

      jack.debug("elements: \(elements)")
    }

  }

  // MARK: Internal Selection

  describe("internal selection") {

    it("emits nil initially") {
      let selections = model.selection.elements(in: 0.01)
      expect(selections) == [nil] as [LanguagesModel.Selection?]
    }

  }

  // MARK: Internal Command

  describe("internal command") {

    it("emits retry initially") {
      expect(model.command.value.isRetry).to(beTrue())
    }

    it("emits retry when retry button tapped") {
      input.retryButtonTap.accept(())
      expect(model.command.value.isRetry).to(beTrue())
    }

    it("emits movePinned when user move a pinned item") {
      input.movePinnedItem.accept((from: 0, to: 1))
      expect(model.command.value) == .movePinned(from: 0, to: 1)
    }

    it("pin selected history item") {
      model.selection.accept(selectHistory)
      input.pinButtonTap.accept(())
      expect(model.command.value) == .pin("History")
    }

    it("unpin selected pinned item") {
      model.selection.accept(selectPinned)
      input.pinButtonTap.accept(())
      expect(model.command.value) == .unpin("Pinned")
    }

    it("pin selected other item") {
      model.selection.accept(selectOther)
      input.pinButtonTap.accept(())
      expect(model.command.value) == .pin("Other")
    }

  }

  // MARK: Pin Button State

  describe("pin button state") {

    it("emits hide initially") {
      let pinButtonStates = output.pinButtonState.elements(in: 0.01)
      expect(pinButtonStates.count) == 1
      expect(pinButtonStates.first!) == .hide
    }

    it("emits Pin when history item is selected") {
      model.selection.accept(selectHistory)
      expect(output.pinButtonState.value) == .show("Pin")
    }

    it("emits Unpin when pinned item is selected") {
      model.selection.accept(selectPinned)
      expect(output.pinButtonState.value) == .show("Unpin")
    }

    it("emits Pin when other item is selected") {
      model.selection.accept(selectOther)
      expect(output.pinButtonState.value) == .show("Pin")
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
    let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    let oneSecond = Observable<Int>.timer(interval, scheduler: scheduler)
    return try! asObservable()
      .takeUntil(oneSecond)
      .jack("takeUntil")
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
