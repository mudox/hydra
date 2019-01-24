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
    di.autoregister(
      LanguagesServiceType.self,
      initializer: LanguagesServiceStub.init
    )

    model = TrendModel()
    input = model.input
    output = model.output

    input.barSelection.accept((index: 0, item: "All"))
  }

  // MARK: Initial bar state

  it("initial bar state") {
    let seq = output.barState
      .asObservable()
      .take(1)

    expect(seq.map { $0.items }).first == ["All", "Pinned", "Unknown"]
    expect(seq.map { $0.index }).first == 0
  }

  // MARK: Initial collection view data

  it("initial collection view data") {
    let seq = output.collectionViewData
      .asObservable()
      .take(1)

    let first = try! seq.toBlocking().first()!
    let language = first[0].items[0].language
    expect(language) == "All"
  }

  // MARK: Initial color state

  it("initial color") {
    expect(TrendModel.color.value) == .brand
  }

  // MARK: React to languages flow result

  it("react to langauges flow result") {
    let pinned = ["Pinned"]

    var result: LanguagesFlowResult
    result = .init(selected: "Select", pinned: pinned)
    input.languagesFlowResult.accept(result)
    expect(output.barState.value.items) == ["All", "Select", "Pinned", "Unknown"]
    expect(output.barState.value.index) == 1

    input.barSelection.accept((1, "Select"))
    // nil `selected` does not change bar index
    result = .init(selected: nil, pinned: pinned)
    input.languagesFlowResult.accept(result)
    expect(output.barState.value.items) == ["All", "Select", "Pinned", "Unknown"]
    expect(output.barState.value.index) == 1
  }

} }
