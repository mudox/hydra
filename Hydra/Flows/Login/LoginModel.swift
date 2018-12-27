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
  var login: Action<LoginInput, LoginOutput> { get }
  var dismiss: Signal<Void> { get }
}

protocol LoginModelType: LoginModelInput, LoginModelOutput {
  init(service: LoginServiceType)
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

  private let _hud = PublishRelay<MBPCommand>()
  let hud: Signal<MBPCommand>

  private let _dismiss = PublishRelay<Void>()
  let dismiss: Signal<Void>

  var login: Action<LoginInput, LoginOutput>

  // MARK: - Life cycle

  deinit {
    jack.func().info("💀 \(type(of: self))", format: .bare)
  }

  required init(service: LoginServiceType) {

    hud = _hud.asSignal()
    dismiss = _dismiss.asSignal()

    backTap.bind(to: _dismiss).disposed(by: disposeBag)

    let inputs = Observable
      .combineLatest(username, password) { (username: $0, password: $1) }
      .share()

    let isInputValid = inputs.map(service.validate)

    login = Action(enabledIf: isInputValid) { username, password in
      service.login(username: username, password: password)
    }

    loginTap
      .withLatestFrom(inputs)
      .bind(to: login.inputs)
      .disposed(by: disposeBag)

    setupHUD()
  }

  func setupHUD() {

    let begin = login.executing
      .filter { $0 == true }
      .map { _ -> MBPCommand in
        return .begin(message: "Logging in", mode: .indeterminate)
      }

    let success = login.elements
      .map { [weak self] _ -> MBPCommand in
        return .success(message: "Logged in") { hud in
          hud.completionBlock = {
            self?._dismiss.accept(())
          }
        }
      }

    let error = login.errors
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
      .bind(to: _hud)
      .disposed(by: disposeBag)
  }

}
