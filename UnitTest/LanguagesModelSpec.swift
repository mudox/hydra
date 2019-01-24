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

  // MARK: Initial bar state

  it("initial bar state") {
    let seq = output.state
      .asObservable()
      .take(1)

//    expect(seq.map { $0.items }).first == ["All", "Pinned", "Unknown"]
//    expect(seq.map { $0.index }).first == 0
  }

} }
