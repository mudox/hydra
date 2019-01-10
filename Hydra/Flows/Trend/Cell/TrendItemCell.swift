import UIKit

import RxCocoa
import RxSwift

import SnapKit

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendItemCell: UICollectionViewCell {

  static let retryNotification = Notification.Name("io.github.Mudox.Hydra.Trend.retry")

  var disposeBag = DisposeBag()

  let badge = BadgeView()

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    tintColor = .dark
    backgroundColor = .white

    setupLayer()

    setupErrorLabel()
    setupErrorStackView()

    setupBadge()
  }

  // MARK: - View

  private var errorLabel: UILabel!
  private var retryButton: RetryButton!
  private var errorStackView: UIStackView!

  static let size = CGSize(width: 270, height: 170)

  func setupLayer() {
    layer.do {
      // Shape
      $0.cornerRadius = .cornerRadius
      $0.masksToBounds = false
    }
  }

  func setupBadge() {
    contentView.addSubview(badge)
    badge.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(snp.bottom)
    }
  }

  func setupErrorLabel() {
    errorLabel = UILabel().then {
      $0.text = "Oops"
      $0.textColor = .emptyDark
      $0.font = .text
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 2
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupErrorStackView() {
    retryButton = RetryButton()

    let views: [UIView] = [errorLabel, retryButton]
    errorStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 12
    }

    contentView.addSubview(errorStackView)
    errorStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.lessThanOrEqualToSuperview().inset(CGFloat.margin)
    }

    errorLabel.snp.makeConstraints { make in
      make.width.lessThanOrEqualTo(contentView).inset(24)
    }
  }

  func show(rank: Int, color: UIColor) {
    // Self
    backgroundColor = .white

    // Center
    errorStackView.isHidden = true

    // Badge
    badge.show(rank: rank, color: color)
  }

  func showLoading() {
    // Self
    backgroundColor = .emptyLight

    // Center
    errorStackView.isHidden = true

    // Badge
    badge.showLoading()
  }

  func show(error: Error, context: Trend.Context) {
    // Self
    backgroundColor = .emptyLight

    // Error label
    errorStackView.isHidden = false
    switch error {
    case Trending.Error.isDissecting:
      errorLabel.text = "Server is updating the data..."
    case Trending.Error.htmlParsing:
      errorLabel.text = "Internal Error"
    default:
      errorLabel.text = "Loading Error"
    }
    retryButton.isHidden = false

    // Retry button
    disposeBag = DisposeBag()
    retryButton.rx.tap
      .subscribe(onNext: { _ in
        NotificationCenter.default.post(
          name: TrendItemCell.retryNotification,
          object: nil,
          userInfo: ["context": context]
        )
      })
      .disposed(by: disposeBag)

    // Badge
    badge.showError()
  }

}