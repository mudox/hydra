import Action
import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack("LoginViewModel")

// MARK: Interface

protocol LoginViewModelInput {
  var username: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var loginTap: PublishRelay<Void> { get }
}

typealias LoginInput = (username: String, password: String)

typealias LoginOutput = GitHub.Service.AuthorizeResponse

protocol LoginViewModelOutput {
  var hudCommands: Driver<MBPCommand> { get }
  var loginAction: Action<LoginInput, LoginOutput> { get }
}

protocol LoginViewModelType: LoginViewModelInput, LoginViewModelOutput {
  init(
    flow: LoginFlowType,
    loginService: LoginServiceType
  )
}

extension LoginViewModelType {
  var input: LoginViewModelInput { return self }
  var output: LoginViewModelOutput { return self }
}

// MARK: - Impelementation

class LoginViewModel: LoginViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: - Output

  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())

  var hudCommands: Driver<MBPCommand> {
    return hudRelay.asDriver()
  }

  var loginAction: Action<LoginInput, LoginOutput>

  // MARK: - Life cycle

  required init(flow: LoginFlowType, loginService: LoginServiceType) {

    let inputs = Observable
      .combineLatest(username, password) { (username: $0, password: $1) }
      .share()

    // isLoginButtonEnabled
    let isInputValid = inputs.map(loginService.validate)

    loginAction = Action(enabledIf: isInputValid, workFactory: { username, password in
      loginService.login(username: username, password: password)
    })

    loginTap
      .withLatestFrom(inputs)
      .bind(to: loginAction.inputs)
      .disposed(by: disposeBag)

    loginAction
      .elements
      .take(1)
      .ignoreElements()
      .subscribe(
        onCompleted: {
          flow.complete()
        },
        onError: {
          jack.descendant("init.login").error("failed to login with: \($0)")
        }
      )
      .disposed(by: disposeBag)

  }

}
