import UIKit

import Action
import RxCocoa
import RxSwift

import Then

import JacKit
import MudoxKit

import GitHub

private let jack = Jack()

private extension UIFont {
}

class LoginViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

  // MARK: - View

  let titleLabel = UILabel()

  let usernameLabel = UILabel()
  let usernameField = LoginTextField()

  let passwordLabel = UILabel()
  let passwordField = LoginTextField()

  let loginButton = UIButton()

  let margin: CGFloat = 30
  let fieldGap: CGFloat = 40
  let sectionGap: CGFloat = 100

  func setupView() {
    view.backgroundColor = .white

    setupTitleLabel()
    setupInputFields()
    setupLoginButton()

    let inputFields: [UIView] = [usernameField, passwordField]
    let inputStackView = UIStackView(arrangedSubviews: inputFields).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .fill
      $0.spacing = fieldGap
    }

    let sections: [UIView] = [titleLabel, inputStackView, loginButton]
    let stackView = UIStackView(arrangedSubviews: sections).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .fill
      $0.spacing = sectionGap
    }

    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(margin)
    }

  }

  func setupTitleLabel() {
    titleLabel.do {
      $0.text = "Welcome Back!"
      $0.textColor = .black
      $0.font = .loginTitle
      $0.textAlignment = .left
    }

  }

  func setupInputFields() {
    usernameField.textField.do {
      $0.keyboardType = .emailAddress
      $0.returnKeyType = .next
      $0.textContentType = .username
    }
    usernameField.tipLabel.text = "Username"

    passwordField.textField.do {
      $0.keyboardType = .asciiCapable
      $0.returnKeyType = .go
      $0.textContentType = .password
      $0.isSecureTextEntry = true
    }
    passwordField.tipLabel.text = "Password"
  }

  func setupLoginButton() {
    let height = 50
    let cornerRadius: CGFloat = 6

    loginButton.do {
      $0.setTitle("LOGIN", for: .normal)
      $0.titleLabel?.font = .loginButton
      $0.setBackgroundImage(UIImage.mdx.color(.brand), for: .normal)

      $0.layer.masksToBounds = true
      $0.layer.cornerRadius = cornerRadius
    }

    loginButton.snp.makeConstraints { make in
      make.height.equalTo(height)
    }
  }

  // MARK: - Model

  var disposeBag = DisposeBag()

  var model: LoginViewModel!

  func setupModel() {
    // model <- view
    disposeBag.insert(
      usernameField.textField.rx.text.orEmpty.bind(to: model.input.username),
      passwordField.textField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.rx.tap.bind(to: model.input.loginTap)
    )

    // model -> view
    disposeBag.insert(
      model.output.loginAction.enabled.bind(to: loginButton.rx.isEnabled)
    )
  }

}
