import Action
import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack("LoginModel")

typealias LoginInput = (username: String, password: String)

typealias LoginOutput = GitHub.Service.AuthorizeResponse

// MARK: Interface

protocol LoginModelInput {
  var backTap: PublishRelay<Void> { get }
  var username: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var loginTap: PublishRelay<Void> { get }
}

protocol LoginModelOutput {
  var hud: Signal<MBPCommand> { get }
  var loginAction: Action<LoginInput, LoginOutput> { get }
}

protocol LoginModelType: LoginModelInput, LoginModelOutput {
  init(
    flow: LoginFlowType,
    loginService: LoginServiceType
  )
}

extension LoginModelType {
  var input: LoginModelInput { return self }
  var output: LoginModelOutput { return self }
}

// MARK: - Impelementation

class LoginModel: LoginModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

  let backTap = PublishRelay<Void>()
  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: - Output

  private var hudRelay = PublishRelay<MBPCommand>()

  var hud: Signal<MBPCommand> {
    return hudRelay.asSignal()
  }

  var loginAction: Action<LoginInput, LoginOutput>

  // MARK: - Life cycle

  private let flow: LoginFlowType
  private let loginService: LoginServiceType

  deinit {
    jack.func().info("💀 \(type(of: self))", format: .bare)
  }

  required init(flow: LoginFlowType, loginService: LoginServiceType) {

    self.flow = flow
    self.loginService = loginService

    let inputs = Observable
      .combineLatest(username, password) { (username: $0, password: $1) }
      .share()

    let isInputValid = inputs.map(loginService.validate)

    loginAction = Action(enabledIf: isInputValid) { username, password in
      loginService.login(username: username, password: password)
    }

    backTap
      .bind { [weak self] _ in
        self?.flow.complete()
      }
      .disposed(by: disposeBag)

    loginTap
      .withLatestFrom(inputs)
      .bind(to: loginAction.inputs)
      .disposed(by: disposeBag)

    setupHUD()
  }

  func setupHUD() {

    let begin = loginAction.executing
      .filter { $0 == true }
      .map { _ -> MBPCommand in
        return .begin(message: "Logging in", mode: .indeterminate)
      }

    let success = loginAction.elements
      .map { [weak self] _ -> MBPCommand in
        return .success(message: "Logged in") { hud in
          hud.completionBlock = {
            self?.flow.complete()
          }
        }
      }

    let error = loginAction.errors
      .map { error -> MBPCommand in
        switch error {
        case let ActionError.underlyingError(error):
          switch error {
          case GitHubError.invalidCredential:
            return .error(title: "Error", message: "invalid username or password", hideIn: 2)
          default:
            return .error(message: "Error occured")
          }
        default:
          return .error(message: "Error occured")
        }
      }

    Observable.merge(begin, success, error)
      .bind(to: hudRelay)
      .disposed(by: disposeBag)
  }

}
