import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

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

      // Shadow
      $0.shadowColor = UI.shadowColor.cgColor
      $0.shadowOffset = UI.shadowOffset
      $0.shadowRadius = UI.shadowRadius
      $0.shadowPath = UIBezierPath(roundedRect: $0.bounds, cornerRadius: 6).cgPath

      $0.shouldRasterize = true
      $0.rasterizationScale = UIScreen.main.scale
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

  func show(rank: Int) {
    backgroundColor = .white

    // Show shadow
    layer.shadowOpacity = UI.shadowOpacity

    // Badge
    badge.showRank(rank)
  }

  func showLoading() {
    backgroundColor = .emptyLight

    // Hide shadow
    layer.shadowOpacity = 0

    // Badge
    badge.showLoading()
  }

}
