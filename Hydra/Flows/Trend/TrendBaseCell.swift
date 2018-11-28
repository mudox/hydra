import UIKit

import RxCocoa
import RxSwift

import SnapKit

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendBaseCell: UICollectionViewCell {

  var badge: TrendRankBadge!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    tintColor = .dark
    backgroundColor = .white

    setupLayer()
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

  @objc dynamic
  func show(rank: Int) {
    backgroundColor = .white

    // Badge
    badge.show(rank: rank)
  }

  @objc dynamic
  func showLoading() {
    backgroundColor = .emptyLight

    // Badge
    badge.showLoading()
  }

}
