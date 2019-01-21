import XCTest

import Nimble
import Quick

import RxBlocking
import RxNimble
import RxTest

import JacKit

@testable import Hydra

private let jack = Jack("Test.TrendModel")

@testable import Hydra

private class ServiceStub: LanguagesServiceType {
  var pinned = ["Test"]
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

  it("initial bar state") {
    let seq = output.barState
      .asObservable()
      .take(1)

    expect(seq.map { $0.items }).first == ["All", "Test", "Unknown"]
    expect(seq.map { $0.index }).first == 0
  }

  it("initial collection data") {
    let seq = output.collectionViewData
      .asObservable()
      .take(1)

    let first = try! seq.toBlocking().first()!
    let language = first[0].items[0].language
    expect(language) == "All"
  }
  }

} }
