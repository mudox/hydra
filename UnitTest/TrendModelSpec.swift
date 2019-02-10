import XCTest

import Nimble
import Quick

import RxBlocking
import RxNimble
import RxTest

import RxCocoa
import RxSwift

import GitHub
import MudoxKit

@testable import Hydra

import JacKit

private let jack = Jack().set(format: .short)

class TrendModelSpec: QuickSpec { override func spec() {

  var model: TrendModel!
  var input: TrendModelInput!
  var output: TrendModelOutput!

  beforeEach {
    swinject.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesServiceStub.init
    )

    model = TrendModel()
    input = model.input
    output = model.output

    input.barSelection.accept((index: 0, item: "All"))
  }

  afterEach {
    // Supress warning from `ClassInstanceCounting`
    model = nil
    input = nil
    output = nil
  }

  // MARK: Bar State

  describe("bar state") {

    it("emit proper initial value") {
      let states = output.languagesBar.elements(in: 0.01)

      expect(states.count) == 1
      expect(states.first!.index) == 0
      expect(states.first!.items) == ["All", "Pinned", "Unknown"]
    }

  }

  // MARK: Collection View Data

  describe("collection view data") {

    it("be all initially") {
      let datas = output.tableViewSections.elements(in: 0.01)

      expect(datas.count) == 1
      expect(datas[0][0].items[0].language) == "All"
    }

    it("show and select non-nil more language") {
      input.moreLanguage.accept("Select")
      expect(output.languagesBar.value.index) == 1
      expect(output.languagesBar.value.items) == ["All", "Select", "Pinned", "Unknown"]
    }

    it("does not change on nil more language") {
      input.moreLanguage.accept(nil)
      expect(output.languagesBar.value.items) == ["All", "Pinned", "Unknown"]
      expect(output.languagesBar.value.index) == 0
    }

  }

  // MARK: Color

  describe("color") {

    it("be brand initially") {
      expect(TrendModel.color.value) == .brand
    }

  }

} }
