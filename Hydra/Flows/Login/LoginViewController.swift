import UIKit

import RxCocoa
import RxKeyboard
import RxSwift

import Then

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class LoginViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

  // MARK: - Subviews

  let scrollView = UIScrollView()
  let contentView = UIView()

  let titleLabel = UILabel()

  let username = LoginTextField()
  let password = LoginTextField()

  let loginButton = LoginButton()

  // MARK: - Constants

  let margin: CGFloat = 40
  let fieldGap: CGFloat = 12
  let titleYOffset: CGFloat = 40

  let titleFont = UIFont.systemFont(ofSize: 30, weight: .bold)

  // MARK: - View

  func setupView() {
    view.backgroundColor = .white

    setupScrollView()
    setupTitleLabel()
    setupInputFields()
    setupStackViews()
    setupKeyboard()
  }

  func setupScrollView() {
    scrollView.do {
      $0.showsHorizontalScrollIndicator = false
      $0.keyboardDismissMode = .interactive
    }

    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.size.equalTo(view)
    }
  }

  func setupTitleLabel() {
    titleLabel.do {
      $0.text = "Welcome Back!"
      $0.textAlignment = .left
      $0.textColor = .black
      $0.font = titleFont

      $0.transform = CGAffineTransform(translationX: 0, y: titleYOffset)
    }

    scrollView.rx.didScroll
      .bind { [weak self] in
        guard let self = self else { return }
        let topMargin = self.view.convert(CGPoint.zero, from: self.titleLabel).y
        let deltaY = max(0, topMargin - self.view.safeAreaInsets.top)
        self.titleLabel.alpha = deltaY / 100
      }
      .disposed(by: disposeBag)
  }

  func setupInputFields() {
    username.textField.do {
      $0.keyboardType = .emailAddress
      $0.returnKeyType = .next
      $0.textContentType = .username
    }
    username.tipLabel.text = "Username"

    password.textField.do {
      $0.keyboardType = .asciiCapable
      $0.returnKeyType = .go
      $0.textContentType = .password
      $0.isSecureTextEntry = true
    }
    password.tipLabel.text = "Password"

    UIControl.rx.createTapStopGroup(
      username.textField,
      password.textField
    )
    .disposed(by: disposeBag)
  }

  func setupStackViews() {
    let textFields: [UIView] = [username, password]
    let fieldsStackView = UIStackView(arrangedSubviews: textFields).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .fill
      $0.spacing = fieldGap
    }

    let sections: [UIView] = [titleLabel, fieldsStackView, loginButton]
    let stackView = UIStackView(arrangedSubviews: sections).then {
      $0.axis = .vertical
      $0.distribution = .equalSpacing
      $0.alignment = .fill
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-titleYOffset + 20)
      make.width.equalToSuperview().multipliedBy(0.8)
      make.height.equalToSuperview().multipliedBy(0.75)
    }
  }

  func setupKeyboard() {
    view.layoutIfNeeded()

    let newBottomMargin: CGFloat = 80

    let y = loginButton.frame.maxY
    let bottomMargin = view.frame.maxY - y
    let offset = bottomMargin - newBottomMargin

    RxKeyboard.instance.willShowVisibleHeight
      .drive(onNext: { [weak self] height in
        self?.scrollView.contentOffset.y += (height - offset)
      })
      .disposed(by: disposeBag)

    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [weak self] height in
        self?.scrollView.do {
          $0.contentInset.bottom = (height - offset)
          $0.scrollIndicatorInsets.bottom = (height - offset)
        }
      })
      .disposed(by: disposeBag)
  }

  // MARK: - Model

  var disposeBag = DisposeBag()

  var model: LoginViewModel!

  func setupModel() {
    // model <- view
    disposeBag.insert(
      username.textField.rx.text.orEmpty.bind(to: model.input.username),
      password.textField.rx.text.orEmpty.bind(to: model.input.password),
      loginButton.button.rx.tap.bind(to: model.input.loginTap)
    )

    // model -> view
    disposeBag.insert(
      model.output.loginAction.enabled.bind(to: loginButton.button.rx.isEnabled)
    )
  }

}
