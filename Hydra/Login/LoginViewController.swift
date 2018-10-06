import RxCocoa
import RxSwift
import UIKit

import MudoxKit

import JacKit

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
    model = LoginViewModel(loginService: LoginService())
  }

  func bindToModel() {
    disposeBag.insert(
      usernameField.rx.text.orEmpty.bind(to: model.input.username),
      passwordField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.rx.tap.bind(to: model.loginTap)
    )
  }

  func bindFromModel() {
  }

}
