import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

import GitHub

private let jack = Jack("Hydra.LoginViewModel")

// MARK: - Protocols

protocol LoginViewModelInput {
  var username: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var loginTap: PublishRelay<Void> { get }
}

protocol LoginViewModelOutput {
  var hud: Driver<MBPCommand> { get }
  var isLoginButtonEnabled: Driver<Bool> { get }
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

// MARK: - View Model

class LoginViewModel: LoginViewModelType {

  enum Error: Swift.Error {
    case weakSelf
    case credential(String)
  }

  let disposeBag = DisposeBag()

  // MARK: - Input

  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: - Output

  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())
  var hud: Driver<MBPCommand> {
    return hudRelay.asDriver()
  }

  private var isLoginButtonEnabledRelay = BehaviorRelay<Bool>(value: false)
  var isLoginButtonEnabled: Driver<Bool> {
    return isLoginButtonEnabledRelay.asDriver()
  }

  // MARK: - Dependencies

  let flow: LoginFlowType
  let loginService: LoginServiceType

  // MARK: - Life cycle

  required init(flow: LoginFlowType, loginService: LoginServiceType) {
    self.flow = flow
    self.loginService = loginService
    bind()
  }

  func bind() {
    let userInput = Observable.combineLatest(username, password).share()

    // isLoginButtonEnabled
    userInput
      .map { [weak self] username, password -> Bool in
        guard let self = self else { throw Error.weakSelf }
        let isUsernameValid = self.loginService.validate(username: username)
        let isPasswordValid = self.loginService.validate(password: password)
        return isUsernameValid && isPasswordValid
      }
      .bind(to: isLoginButtonEnabledRelay)
      .disposed(by: disposeBag)

    loginTap
      .withLatestFrom(userInput)
      .flatMap { [weak self] username, password -> Driver<GitHub.Response<Authorization>> in
        guard let self = self else {
          throw CommonError.weakReference("weak self is nil")
        }

        let scope: GitHub.AuthScope = [.user, .repository, .organization, .notification, .gist]
        return self.loginService.login(username: username, password: password, scope: scope, note: nil)
      }
      .do(
        onError: { error in
          jack.descendant("bind.login.onError").error("login failed with \(error)")
        }
      )
      .take(1)
      .subscribe(onNext: { [weak self] _ in
        self?.flow.complete()
      })
      .disposed(by: disposeBag)

  } // bind()

}
