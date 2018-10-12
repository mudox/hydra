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
    loginService: LoginService,
    credentialService: GitHub.CredentialServiceType,
    githubService: GitHub.Service
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
  let credentialService: GitHub.CredentialServiceType
  let githubService: GitHub.Service

  // MARK: - Life cycle

  required init(
    loginService: LoginService,
    credentialService: GitHub.CredentialServiceType,
    githubService: GitHub.Service
  ) {
    self.loginService = loginService
    self.credentialService = credentialService
    self.githubService = githubService
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
      .map { [weak self] username, password -> GitHub.AuthParameter in
        guard let self = self else { throw Error.weakSelf }

        let user = (name: username, password: password)

        guard let app = self.credentialService.app else {
          throw Error.credential("need an GitHub OAuth app key & secret")
        }

        let scope: GitHub.AuthScope = [.user, .repository, .organization, .notification, .gist]
        return GitHub.AuthParameter(user: user, app: app, scope: scope, note: "Hydra login")
      }
      .flatMap(githubService.authorize)
      .subscribe(
        onNext: { _ in
          jack.descendant("bind.login.onNext").info("login succeeded")
        },
        onError: { error in
          jack.descendant("bind.login.onError").error("login failed with \(error)")
        }
      )
      .disposed(by: disposeBag)

  } // bind()

}
