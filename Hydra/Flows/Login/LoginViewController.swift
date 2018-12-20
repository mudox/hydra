import UIKit

import RxCocoa
import RxGesture
import RxKeyboard
import RxSwift
import RxSwiftExt

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

  let backButton = UIButton()

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

    // Subviews
    setupScrollView()
    setupTitleLabel()
    setupInputFields()
    setupStackViews()
    setupBackButton()

    // Keyboard
    tapToDismissKeyboard()
    avoidKeyboard()
  }

  func setupScrollView() {
    scrollView.do {
      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false
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

  func setupBackButton() {
    backButton.do {
      $0.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
    }

    view.addSubview(backButton)
    backButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
      make.leading.equalTo(titleLabel)
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
      make.leading.trailing.equalToSuperview().inset(30)
      make.top.equalTo(80)
      make.bottom.equalTo(-86)
    }
  }

  // MARK: - Keyboard


  func avoidKeyboard() {
    view.layoutIfNeeded()

    let margin: CGFloat = 10
    let maxY = loginButton.convert(loginButton.bounds, to: view).maxY
    let y = view.bounds.maxY - maxY

    RxKeyboard.instance.willShowVisibleHeight
      .drive(onNext: { [weak self] height in
        jack.func().debug("willShowVisibleHeight: \(height)")
        guard self?.scrollView.contentOffset.y == 0 else { return }
        let newY = height + margin
        let inset = max(0, newY - y)
        self?.scrollView.contentOffset.y = inset
      })
      .disposed(by: disposeBag)

    RxKeyboard.instance.visibleHeight
      .debounce(0) // skip immediate hide before show event in the same run loop
      .drive(onNext: { [weak self] height in
        jack.func().debug("visibleHeight: \(height)")
        if height == 0 {
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self?.scrollView.contentInset.bottom = 0
          })
        } else {
          let newY = height + margin
          let inset = max(0, newY - y)
          self?.scrollView.contentInset.bottom = inset
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
