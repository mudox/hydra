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

import Yams

@testable import Hydra

import JacKit
private let jack = Jack().set(format: .short)

@testable import Hydra

private class ServiceStub: LanguagesServiceType {

  let pinned = ["Pinned"]

  let all = Single<[GitHub.Language]>
    .just([
      GitHub.Language(name: "Select", colorString: "#333"),
      GitHub.Language(name: "Pinned", colorString: "#222"),
    ])
}

class TrendModelSpec: QuickSpec { override func spec() {

  var model: TrendModel!
  var input: TrendModelInput!
  var output: TrendModelOutput!

  beforeEach {
    di.register(LanguagesServiceType.self) { _ in
      ServiceStub()
    }

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
