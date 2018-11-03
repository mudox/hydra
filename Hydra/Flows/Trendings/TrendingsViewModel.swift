import Action
import RxCocoa
import RxSwift
import RxSwiftExt

import UIKit

import JacKit
import MudoxKit

//import GitHub

private let jack = Jack("TrendingsViewModel")

// MARK: Interface

protocol TrendingsViewModelInput {
//  var username: BehaviorRelay<String> { get }
//  var password: BehaviorRelay<String> { get }
//  var TrendingsTap: PublishRelay<Void> { get }
}

protocol TrendingsViewModelOutput {
//  var hudCommands: Driver<MBPCommand> { get }
//  var TrendingsAction: Action<TrendingsInput, TrendingsOutput> { get }
}

protocol TrendingsViewModelType: TrendingsViewModelInput, TrendingsViewModelOutput {
  init(
//    flow: TrendingsFlowType,
//    TrendingsService: TrendingsServiceType
  )
}

extension TrendingsViewModelType {
  var input: TrendingsViewModelInput { return self }
  var output: TrendingsViewModelOutput { return self }
}

// MARK: - Impelementation

class TrendingsViewModel: TrendingsViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

//  let username = BehaviorRelay<String>(value: "")
//  let password = BehaviorRelay<String>(value: "")
//  let TrendingsTap = PublishRelay<Void>()

  // MARK: - Output

//  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())
//
//  var hudCommands: Driver<MBPCommand> {
//    return hudRelay.asDriver()
//  }
//
//  var TrendingsAction: Action<TrendingsInput, TrendingsOutput>

  // MARK: - Life cycle

  required init() {

  }

}
