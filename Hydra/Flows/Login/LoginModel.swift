import Action
import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

private typealias LoginInput = (username: String, password: String)
private typealias LoginOutput = GitHub.Service.AuthorizeResponse
private typealias LoginAction = Action<LoginInput, LoginOutput>

// MARK: Interface

protocol LoginModelInput {
  var backTap: PublishRelay<Void> { get }

  var username: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }

  var loginTap: PublishRelay<Void> { get }
}

protocol LoginModelOutput {
  var hud: Signal<MBPCommand> { get }
  var loginButtonEnabled: Driver<Bool> { get }
  var complete: Single<Void> { get }
}

protocol LoginModelType: LoginModelInput, LoginModelOutput {
  init()
}

extension LoginModelType {
  var input: LoginModelInput { return self }
  var output: LoginModelOutput { return self }
}

// MARK: - Impelementation

class LoginModel: ViewModel, LoginModelType {

  private var action: LoginAction!
  private let service = di.resolve(LoginServiceType.self)!

  // MARK: - Input

  let backTap = PublishRelay<Void>()
  let username = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let loginTap = PublishRelay<Void>()

  // MARK: - Output

  private let _hud: PublishRelay<MBPCommand>
  let hud: Signal<MBPCommand>

  private var _complete: PublishRelay<Void>
  let complete: Single<Void>

  private var _loginButtonEnabled: BehaviorRelay<Bool>
  let loginButtonEnabled: Driver<Bool>

  // MARK: - Life cycle

  override required init() {
    _hud = PublishRelay<MBPCommand>()
    hud = _hud.asSignal()

    _complete = PublishRelay<Void>()
    complete = _complete.take(1).asSingle()

    _loginButtonEnabled = BehaviorRelay<Bool>(value: false)
    loginButtonEnabled = _loginButtonEnabled.asDriver()

    super.init()

    backTap.bind(to: _complete).disposed(by: bag)

    setupAction()
    setupHUD()
  }

  private func setupAction() {
    let inputs = Observable
      .combineLatest(username, password) { (username: $0, password: $1) }
      .share()

    let isInputValid = inputs.map(service.validate)

    action = LoginAction(enabledIf: isInputValid) {
      [weak self] username, password -> Observable<LoginOutput> in
      self?.service.login(username: username, password: password).asObservable()
        ?? Observable.empty()
    }

    loginTap
      .withLatestFrom(inputs)
      .bind(to: action.inputs)
      .disposed(by: bag)

    action.enabled.bind(to: _loginButtonEnabled)
      .disposed(by: bag)
  }

  private func setupHUD() {

    let begin = action.executing
      .filter { $0 == true }
      .map { _ -> MBPCommand in
        return .begin(message: "Logging in", mode: .indeterminate)
      }

    let success = action.elements
      .map { [weak self] _ -> MBPCommand in
        return .success(message: "Logged in") { hud in
          hud.completionBlock = {
            self?._complete.accept(())
          }
        }
      }

    let error = action.errors
      .map { error -> MBPCommand in
        switch error {
        case let ActionError.underlyingError(error):
          switch error {
          case GitHubError.invalidCredential:
            return .error(message: "invalid username\nor password", hideIn: 2)
          default:
            return .error(message: "Error occured")
          }
        default:
          return .error(message: "Error occured")
        }
      }

    Observable.merge(begin, success, error)
      .bind(to: _hud)
      .disposed(by: bag)
  }

}
