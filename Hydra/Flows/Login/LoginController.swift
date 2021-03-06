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

class LoginController: ViewController {

  // MARK: - Subviews

  let scrollView = UIScrollView()
  let contentView = UIView()

  let backButton = UIButton()

  let titleLabel = UILabel()

  let username = TextField()
  let password = TextField()

  let login = Button()

  // MARK: - Constants

  let margin: CGFloat = 40
  let fieldGap: CGFloat = 12
  let titleYOffset: CGFloat = 40

  let titleFont = UIFont.systemFont(ofSize: 30, weight: .bold)

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .white

    // Subviews

    login.button.aid = .loginButton

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
      $0.aid = .dismissLoginBarButtonItem
      $0.tintColor = .brand
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
      .disposed(by: bag)
  }

  func setupInputFields() {
    username.textField.do {
      $0.aid = .usernameTextField
      $0.clearsOnBeginEditing = true
      $0.keyboardType = .emailAddress
      $0.returnKeyType = .next
      $0.textContentType = .username
    }
    username.do {
      $0.clearButton.aid = .clearUsernameButton
      $0.tipLabel.text = "Username"
    }

    password.textField.do {
      $0.aid = .passwordTextField
      $0.clearsOnBeginEditing = true
      $0.keyboardType = .asciiCapable
      $0.returnKeyType = .go
      $0.textContentType = .password
      $0.isSecureTextEntry = true
    }

    password.do {
      $0.clearButton.aid = .clearPasswordButton
      $0.tipLabel.text = "Password"
    }

    UIControl.rx.createTapStopGroup(
      username.textField,
      password.textField
    )
    .disposed(by: bag)
  }

  func setupStackViews() {
    let textFields: [UIView] = [username, password]
    let fieldsStackView = UIStackView(arrangedSubviews: textFields).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .fill
      $0.spacing = fieldGap
    }

    let sections: [UIView] = [titleLabel, fieldsStackView, login]
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

  func tapToDismissKeyboard() {
    let backgroundTap = view.rx
      .tapGesture()
      .when(.recognized)
      .mapTo(())

    let buttonTap = login.button.rx.tap.asObservable()

    Observable.merge(backgroundTap, buttonTap)
      .subscribe(onNext: { [weak self] _ in
        self?.view.endEditing(true)
      })
      .disposed(by: bag)
  }

  func avoidKeyboard() {
    view.layoutIfNeeded()

    let margin: CGFloat = 10
    let maxY = login.convert(login.bounds, to: view).maxY
    let y = view.bounds.maxY - maxY

    RxKeyboard.instance.willShowVisibleHeight
      .drive(onNext: { [weak self] height in
        guard self?.scrollView.contentOffset.y == 0 else { return }
        let newY = height + margin
        let inset = max(0, newY - y)
        self?.scrollView.contentOffset.y = inset
      })
      .disposed(by: bag)

    RxKeyboard.instance.visibleHeight
      .debounce(0) // ⭐️ Skip immediate hide before show event in the same run loop
      .drive(onNext: { [weak self] height in
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
      .disposed(by: bag)
  }

  // MARK: - Model

  let model: LoginModelType = fx()

  override func setupModel() {

    // model <- view

    let input = model.input

    bag.insert(
      backButton.rx.tap.bind(to: input.backTap),
      username.textField.rx.text.orEmpty.bind(to: input.username),
      password.textField.rx.text.orEmpty.bind(to: input.password),
      login.button.rx.tap.bind(to: input.loginTap)
    )

    // model -> view

    let output = model.output

    bag.insert(
      output.loginButtonEnabled.asDriver().drive(login.button.rx.isEnabled),
      output.hud.asSignal().emit(to: view.mbp.hud)
    )

  }

}
