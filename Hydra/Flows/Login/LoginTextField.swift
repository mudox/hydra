import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

extension LoginController {

  class TextField: UIView {

    var disposeBag = DisposeBag()

    // MARK: - Init

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      fatalError("do not use it")
    }

    init() {
      super.init(frame: .zero)

      snp.makeConstraints { make in
        make.height.equalTo(tipHeight + gap + textFieldHeight + bottomMargin)
      }

      setupTextField()
      setupTipLabel()
      setupClearButton()
      setupLine()
    }

    // MARK: - Subviews

    let tipLabel = UILabel()
    let textField = UITextField()
    let clearButton = UIButton()
    let line = UIView()

    // MARK: - Constants

    private let tipHeight = 20
    private let gap = 4
    private let textFieldHeight = 30

    private let clearButtonSize = 12
    private let clearButtonInset = 4

    private let lineHeight = 1
    private let lineHeightHighlighted = 2
    private let bottomMargin = 6

    private let tipFont = UIFont.systemFont(ofSize: 12, weight: .thin)
    private let fieldFont = UIFont.systemFont(ofSize: 18)

    // MARK: - Setup

    func setupTextField() {
      textField.do {
        $0.font = fieldFont
        $0.clearButtonMode = .never
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
      }

      addSubview(textField)
      textField.snp.makeConstraints { make in
        make.height.equalTo(textFieldHeight)
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview().inset(clearButtonSize + clearButtonInset * 2)
        make.bottom.equalToSuperview().inset(bottomMargin)
      }
    }

    func setupTipLabel() {
      tipLabel.do {
        $0.textColor = .light
        $0.font = tipFont
        $0.textAlignment = .left
      }

      addSubview(tipLabel)
      reSnapTipLabel(toTop: false)

      // Move up tipLabel when editing
      textField.rx.shouldHidePlaceHolder
        .drive(onNext: { [weak self] hide in
          guard let self = self else { return }

          UIView.animate(
            withDuration: 0.15, delay: 0,
            usingSpringWithDamping: 0.5, initialSpringVelocity: 1.2,
            options: [],
            animations: {
              self.reSnapTipLabel(toTop: hide)
              self.layoutIfNeeded()
            }
          )
        })
        .disposed(by: disposeBag)
    }

    func reSnapTipLabel(toTop: Bool) {
      tipLabel.snp.remakeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.height.equalTo(tipHeight)
        if toTop {
          make.top.equalToSuperview()
        } else {
          make.centerY.equalTo(textField)
        }
      }
    }

    func setupClearButton() {
      clearButton.do {
        $0.accessibilityIdentifier = "loginTextFieldClearButton"
        $0.setImage(#imageLiteral(resourceName: "Clear Button.pdf"), for: .normal)
        $0.isHidden = true
      }

      addSubview(clearButton)
      clearButton.snp.makeConstraints { make in
        make.size.equalTo(clearButtonSize)
        make.trailing.equalToSuperview().inset(clearButtonInset)
        make.centerY.equalTo(textField)
      }

      textField.rx.shouldHideClearButton
        .drive(clearButton.rx.isHidden)
        .disposed(by: disposeBag)

      clearButton.rx.tap
        .bind { [weak self] in
          self?.textField.text = ""
          self?.clearButton.isHidden = true
        }
        .disposed(by: disposeBag)
    }

    func setupLine() {
      line.do {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .emptyDark
      }

      addSubview(line)
      line.snp.makeConstraints { make in
        make.height.equalTo(lineHeight)
        make.bottom.equalToSuperview()
        make.leading.trailing.equalToSuperview()
      }

      textField.rx.isEditing
        .drive(onNext: { [weak self] isEditing in
          guard let self = self else { return }

          self.line.backgroundColor = isEditing ? .brand : .emptyDark

          self.line.snp.updateConstraints { make in
            make.height.equalTo(isEditing ? self.lineHeightHighlighted : self.lineHeight)
          }
        })
        .disposed(by: disposeBag)
    }

  }

}
