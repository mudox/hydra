import UIKit

import RxCocoa
import RxSwift

import SnapKit

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendBaseCell: UICollectionViewCell {

  var badge: TrendRankBadge!

  var tipLabel: UILabel!
  var retryButton = RetryButton()
  var errorStackView: UIStackView!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    tintColor = .dark
    backgroundColor = .white

    setupLayer()

    setupErrorLabel()
    setupErrorStackView()

    setupBadge()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use")
  }

  func setupLayer() {
    layer.do {
      // Shape
      $0.cornerRadius = UI.cornerRadius
      $0.masksToBounds = false
    }
  }

  func setupBadge() {
    badge = TrendRankBadge()
    contentView.addSubview(badge)
    badge.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(snp.bottom)
    }
  }

  func setupErrorLabel() {
    tipLabel = UILabel().then {
      $0.text = "Loading"
      $0.textColor = .emptyDark
      $0.font = .text
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupErrorStackView() {
    let views: [UIView] = [tipLabel, retryButton]
    errorStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 14
    }

    contentView.addSubview(errorStackView)
    errorStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.lessThanOrEqualToSuperview().inset(UI.margin)
    }
  }

  func show(rank: Int) {
    // Self
    backgroundColor = .white

    // Badge
    badge.show(rank: rank)
  }

  func showLoading() {
    // Self
    backgroundColor = .emptyLight

    // Center
    tipLabel.text = "Loading"
    retryButton.isHidden = true

    // Badge
    badge.showLoading()
  }

  func show(error: Error) {
    // Self
    backgroundColor = .emptyLight

    // Center
    errorStackView.isHidden = false
    tipLabel.text = "Loading Error"
    retryButton.isHidden = false

    // Badge
    badge.showError()
  }

}
