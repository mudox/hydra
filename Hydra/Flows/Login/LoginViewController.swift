import UIKit

import Action
import RxCocoa
import RxSwift

import Then

import JacKit
import MudoxKit

import GitHub

private let jack = Jack()

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
    setupModel()
  }

}

private extension LoginViewController {

  func setupView() {

  }

  func setupModel() {
    // create model
    let githubService = GitHub.Service(credentialService: CredentialService.shared)
    let loginService = LoginService(githubService: githubService)
    model = LoginViewModel(flow: flow, loginService: loginService)

    // model <- view
    disposeBag.insert(
      usernameField.rx.text.orEmpty.bind(to: model.input.username),
      passwordField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.rx.tap.bind(to: model.input.loginTap)
    )

    // model -> view
    disposeBag.insert(
      model.output.loginAction.enabled.bind(to: loginButton.rx.isEnabled)
    )
  }

}
