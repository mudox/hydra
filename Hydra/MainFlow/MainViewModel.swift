import Action
import RxCocoa
import RxSwift
import RxSwiftExt

import UIKit

import JacKit
import MudoxKit

//import GitHub

private let jack = Jack("MainViewModel")

// MARK: Interface

protocol MainViewModelInput {
//  var username: BehaviorRelay<String> { get }
//  var password: BehaviorRelay<String> { get }
//  var MainTap: PublishRelay<Void> { get }
}

protocol MainViewModelOutput {
//  var hudCommands: Driver<MBPCommand> { get }
//  var MainAction: Action<MainInput, MainOutput> { get }
}

protocol MainViewModelType: MainViewModelInput, MainViewModelOutput {
  init(
//    flow: MainFlowType,
//    MainService: MainServiceType
  )
}

extension MainViewModelType {
  var input: MainViewModelInput { return self }
  var output: MainViewModelOutput { return self }
}

// MARK: - Impelementation

class MainViewModel: MainViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

//  let username = BehaviorRelay<String>(value: "")
//  let password = BehaviorRelay<String>(value: "")
//  let MainTap = PublishRelay<Void>()

  // MARK: - Output

//  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())
//
//  var hudCommands: Driver<MBPCommand> {
//    return hudRelay.asDriver()
//  }
//
//  var MainAction: Action<MainInput, MainOutput>

  // MARK: - Life cycle

  required init() {

  }

}
