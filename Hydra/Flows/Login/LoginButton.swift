import UIKit

import RxCocoa
import RxSwift

import SnapKit

extension LoginController {

  class Button: UIView {

    var disposeBag = DisposeBag()

    // MARK: - Init

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      fatalError("do not use it")
    }

    init() {
      super.init(frame: .zero)

      snp.makeConstraints { make in
        make.height.equalTo(buttonHeight + bottomMargin)
      }

      setupButton()
      setupShadow()
    }

    // MARK: - Subviews

    let button = UIButton()
    let shadow = UIView()

    // MARK: - Constants

    private let buttonHeight = 50
    private let cornerRadius: CGFloat = 6
    private let bottomMargin = 30
    private let shadowRadius: CGFloat = 18

    private let font = UIFont.systemFont(ofSize: 18, weight: .medium)

    // MARK: - Setup

    func setupButton() {
      button.do {
        $0.setTitle("LOGIN", for: .normal)
        $0.titleLabel?.font = font
        $0.setBackgroundImage(UIImage.mdx.color(.brand), for: .normal)

        $0.layer.cornerRadius = cornerRadius
        $0.layer.masksToBounds = true
      }

      addSubview(button)
      button.snp.makeConstraints { make in
        make.height.equalTo(buttonHeight)
        make.leading.trailing.top.equalToSuperview()
      }

    }

    func setupShadow() {
      shadow.do {
        $0.backgroundColor = .white
      }

      shadow.layer.do {
        $0.cornerRadius = 15
        $0.masksToBounds = false

        $0.shadowOpacity = 0.3
        $0.shadowOffset = CGSize(width: 0, height: 10)
        $0.shadowColor = UIColor.brand.cgColor
        $0.shadowRadius = shadowRadius
      }

      insertSubview(shadow, at: 0)
      shadow.snp.makeConstraints { make in
        make.leading.trailing.equalTo(button).inset(shadowRadius + 20)
        make.height.equalTo(30)
        make.bottom.equalTo(button)
      }
    }

  }
}
