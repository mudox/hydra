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
    bindToModel()
    bindFromModel()
  }

  func createModel() {
    model = LoginViewModel(
      loginService: LoginService(),
      credentialService: CredentialService.shared,
      githubService: GitHub.Service(credentialService: CredentialService.shared)
    )
  }

  func bindToModel() {
    disposeBag.insert(
      usernameField.rx.text.orEmpty.bind(to: model.input.username),
      passwordField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.rx.tap.bind(to: model.input.loginTap)
    )
  }

  func bindFromModel() {
    disposeBag.insert (
      model.output.hud.drive(view.mbp.hud),
      model.output.isLoginButtonEnabled.drive(loginButton.rx.isEnabled)
    )
  }

}
