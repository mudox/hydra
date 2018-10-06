import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import JacKit
fileprivate let jack = Jack().set(level: .verbose)

// MARK: - Protocols

protocol LoginViewModelInput {
  var username: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var loginTap: PublishRelay<Void> { get }
}

protocol LoginViewModelOutput {
  var hud: PublishRelay<MBPCommand> { get }
  var isLoginButtonEnabled: BehaviorRelay<Bool> { get }

}

protocol LoginViewModelType: LoginViewModelInput, LoginViewModelOutput {
  var input: LoginViewModelInput { get }
  var output: LoginViewModelOutput { get }
}

extension LoginViewModelType {
  var input: LoginViewModelInput { return self }
  var output: LoginViewModelOutput { return self }
}

// MARK: - View Model

class LoginViewModel: LoginViewModelType {

  enum Error: Swift.Error {
    case weakSelf
  }

  // MARK: Input

  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: Output

  let hud = PublishRelay<MBPCommand>()
  let isLoginButtonEnabled = BehaviorRelay<Bool>(value: false)

  // MARK: - Properties

  let disposeBag = DisposeBag()
  let loginService: LoginService

  // MARK: - Life cycle

  init(loginService: LoginService) {
    self.loginService = loginService
    bind()
  }

  func bind() {
    // isLoginButtonEnabled
    Observable
      .combineLatest(username, password)
      .map { [weak self] username, password -> Bool in
        guard let self = self else { throw Error.weakSelf }
        let isUsernameValid = self.loginService.validate(username: username)
        let isPasswordValid = self.loginService.validate(password: password)
        return isUsernameValid && isPasswordValid
      }
      .bind(to: isLoginButtonEnabled)
      .disposed(by: disposeBag)

    // login
  }
}
