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

  let oneSecond = Observable<Int>.timer(1, scheduler: MainScheduler.instance)

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

  fit("initial bar state") {
    let states = try! output.state
      .asObservable()
      .takeUntil(oneSecond)
      .toBlocking()
      .toArray()

    expect(states.count) == 1
    
    switch states.first! {
    case .error:
      assertionFailure()
    case .loading, .value:
      break
    }
  }

} }
