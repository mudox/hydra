import UIKit

import NVActivityIndicatorView
import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendRankBadge: UIView {

  private let diameter: CGFloat = 20
  private var radius: CGFloat { return diameter / 2 }

  var rankLabel: UILabel!
  var indicator: NVActivityIndicatorView!

  init() {
    super.init(frame: .zero)

    backgroundColor = .highlight

    // Layer
    layer.do {
      // Shape
      $0.borderColor = UIColor.white.cgColor
      $0.borderWidth = 1
      $0.cornerRadius = radius

      // Drop shadow
      $0.masksToBounds = false
      $0.shouldRasterize = true
      $0.rasterizationScale = UIScreen.main.scale

      $0.shadowColor = UI.shadowColor.cgColor
      $0.shadowOffset = UI.shadowOffset
      $0.shadowRadius = UI.shadowRadius
      $0.shadowPath = UIBezierPath(ovalIn: CGRect(x: -1, y: -1, width: diameter + 1, height: diameter + 1)).cgPath
    }

    // Fixed size
    snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: diameter, height: diameter))
    }

    // Rank label
    rankLabel = UILabel().then {
      $0.text = "1"
      $0.textColor = .white
      $0.font = UIFont(name: "American Typewriter", size: 14)
      $0.textAlignment = .center
    }

    addSubview(rankLabel)
    rankLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
    }

    // Loading indicator
    indicator = NVActivityIndicatorView(
      frame: .zero,
      type: .ballScaleRippleMultiple,
      color: .white
    )
    addSubview(indicator)
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalToSuperview().inset(2.5)
    }

  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  func showLoading() {
    // Badge
    isHidden = false
    backgroundColor = .lightGray
    layer.shadowOpacity = 0
    layer.borderWidth = 2.5
    transform = .init(scaleX: 1.15, y: 1.15)

    // Indicator
    indicator.startAnimating()

    // Rank Label
    rankLabel.isHidden = true

  }

  func showRank(_ rank: Int) {
    jack.descendant("rank.didSet").assert(rank > 0, "rank should >= 1")

    // Hide for rank after 9
    if rank > 9 {
      isHidden = true
      return
    }

    // Badge
    isHidden = false
    backgroundColor = .highlight
    layer.shadowOpacity = UI.shadowOpacity
    layer.borderWidth = 1
    transform = .identity

    // Indicator
    indicator.stopAnimating()

    // Rank label
    rankLabel.isHidden = false
    rankLabel.text = rank.description
  }

}
