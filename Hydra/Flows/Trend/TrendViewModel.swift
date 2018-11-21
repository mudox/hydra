import UIKit

import Action
import RxCocoa
import RxSwift
import RxSwiftExt

import GitHub

import JacKit
import MudoxKit

private let jack = Jack("TrendViewModel")

// MARK: Interface

protocol TrendViewModelInput {
//  var username: BehaviorRelay<String> { get }
//  var password: BehaviorRelay<String> { get }
//  var TrendTap: PublishRelay<Void> { get }
}

protocol TrendViewModelOutput {
//  var hudCommands: Driver<MBPCommand> { get }
//  var TrendAction: Action<TrendInput, TrendOutput> { get }
}

protocol TrendViewModelType: TrendViewModelInput, TrendViewModelOutput {
  init(
//    flow: TrendFlowType,
//    TrendService: TrendServiceType
  )
}

extension TrendViewModelType {
  var input: TrendViewModelInput { return self }
  var output: TrendViewModelOutput { return self }
}

// MARK: - Impelementation

class TrendViewModel: TrendViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

//  let username = BehaviorRelay<String>(value: "")
//  let password = BehaviorRelay<String>(value: "")
//  let TrendTap = PublishRelay<Void>()

  // MARK: - Output

//  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())
//
//  var hudCommands: Driver<MBPCommand> {
//    return hudRelay.asDriver()
//  }
//
//  var TrendAction: Action<TrendInput, TrendOutput>

  // MARK: - Life cycle

  required init() {

  }

}
