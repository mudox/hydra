import UIKit

import RxCocoa
import RxSwift

import SnapKit

class LanguageCell: UICollectionViewCell {

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupView()
  }

  // MARK: - Subviews

  let label = UILabel()

  // MARK: - Constants

  let height: CGFloat = 24

  // MARK: - Setup

  func setupView() {

    backgroundView = UIView().then {
      $0.backgroundColor = .bgDark
    }

    layer.do {
      $0.masksToBounds = true
      $0.cornerRadius = height / 2
    }

    label.do {
      $0.textAlignment = .center
      $0.font = .text
      $0.textColor = .black
    }

    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(height / 2)
      make.height.equalTo(height)
      make.top.bottom.equalToSuperview()
    }
  }

  // MARK: - Model

  var disposeBag = DisposeBag()

  override var isSelected: Bool {
    didSet {
      if isSelected {
        label.textColor = .white
        backgroundView?.backgroundColor = .brand
      } else {
        label.textColor = .black
        backgroundView?.backgroundColor = .bgDark
      }
    }
  }

  func show(language: String) {
    label.text = language
  }

}
