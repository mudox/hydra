import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

import GitHubKit

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
    loginService: LoginService,
    githubService: GitHubKit.GitHubService,
    credentialService: CredentialService
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
  }

  let disposeBag = DisposeBag()

  // MARK: Input

  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: Output

  private var hudRelay = BehaviorRelay<MBPCommand>(value: .hide())
  var hud: Driver<MBPCommand> {
    return hudRelay.asDriver()
  }

  private var isLoginButtonEnabledRelay = BehaviorRelay<Bool>(value: false)
  var isLoginButtonEnabled: Driver<Bool> {
    return isLoginButtonEnabledRelay.asDriver()
  }

  // MARK: - Dependencies

  let loginService: LoginService
  let githubService: GitHubService
  let credentialService: CredentialService

  // MARK: - Life cycle

  required init(
    loginService: LoginService,
    githubService: GitHubKit.GitHubService,
    credentialService: CredentialService
  ) {
    self.loginService = loginService
    self.githubService = githubService
    self.credentialService = credentialService
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
      .bind(to: isLoginButtonEnabledRelay)
      .disposed(by: disposeBag)

    // login
//    githubService
//      .authorize()
//      .do(onSuccess: { [weak self] response in
//        guard let `self` = self else {
//          Jack("LoginViewModel.login").warn("Weak self gone")
//          return
//        }
//        let authorization = response.payload
//        self.credentialService.
//
//      })
  }
}
