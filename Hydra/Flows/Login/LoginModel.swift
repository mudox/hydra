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
  var hud: PublishRelay<MBPCommand> { get }
  var loginButtonEnabled: BehaviorRelay<Bool> { get }
  var complete: Completable { get }
}

protocol LoginModelType: LoginModelInput, LoginModelOutput {}

extension LoginModelType {
  var input: LoginModelInput { return self }
  var output: LoginModelOutput { return self }
}

// MARK: - Impelementation

class LoginModel: ViewModel, LoginModelType {

  private var action: LoginAction!
  private let service: LoginServiceType = fx()

  // MARK: - Input

  let backTap: PublishRelay<Void>
  let username: BehaviorRelay<String>
  let password: BehaviorRelay<String>
  let loginTap: PublishRelay<Void>

  // MARK: - Output

  let hud: PublishRelay<MBPCommand>
  let loginButtonEnabled: BehaviorRelay<Bool>

  private let _complete: PublishRelay<Void>
  let complete: Completable

  // MARK: - Life cycle

  required override init() {
    // Inputs
    backTap = .init()
    username = .init(value: "")
    password = .init(value: "")
    loginTap = .init()

    // Outputs
    hud = .init()
    loginButtonEnabled = .init(value: false)

    _complete = .init()
    complete = Observable
      .merge(backTap.asObservable(), _complete.asObservable())
      .take(1)
      .ignoreElements()

    super.init()

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

    action.enabled.bind(to: loginButtonEnabled)
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

    Observable
      .merge(begin, success, error)
      .bind(to: hud)
      .disposed(by: bag)
  }

}
