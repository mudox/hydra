import UIKit

import RxCocoa
import RxSwift

import Then

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(level: .verbose)

class LoginViewController: UIViewController {

  var disposeBag = DisposeBag()

  var model: LoginViewModel!

  var flow: LoginFlow!

  // MARK: Outlets

  @IBOutlet private var usernameField: UITextField!
  @IBOutlet private var passwordField: UITextField!

  @IBOutlet private var loginButton: UIButton!

  // MARK: Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    bindView()
    setupModel()
  }

}

private extension LoginViewController {

  func setupView() {

  }

  func bindView() {

  }

  func setupModel() {
    createModel()
    viewToModel()
    modelToView()
  }

  func createModel() {
    let githubService = GitHub.Service(credentialService: CredentialService.shared)
    let loginService = LoginService(githubService: githubService)
    model = LoginViewModel(flow: flow, loginService: loginService)
  }

  func viewToModel() {
    disposeBag.insert(
      usernameField.rx.text.orEmpty.bind(to: model.input.username),
      passwordField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.rx.tap.bind(to: model.input.loginTap)
    )
  }

  func modelToView() {
    disposeBag.insert(
      model.output.hud.drive(view.mbp.hud),
      model.output.isLoginButtonEnabled.drive(loginButton.rx.isEnabled)
    )
  }

}
