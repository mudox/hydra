import UIKit

import NVActivityIndicatorView
import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendRankBadge: UIView {

  private let innerDiameter: CGFloat = 18
  private let borderWidth: CGFloat = 3

  private var innerRadius: CGFloat { return innerDiameter / 2 }
  private var outerRadius: CGFloat  { return innerRadius + borderWidth }
  private var outerDiameter: CGFloat  { return outerRadius * 2 }

  var rankLabel: UILabel!
  var contentView: UIView!
  var indicator: NVActivityIndicatorView!

  init() {
    super.init(frame: .zero)

    setupView()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  func setupView() {
    // Self to mimic border
    backgroundColor = .backDark
    layer.cornerRadius = outerRadius

    // Fixed size
    snp.makeConstraints { make in
      make.size.equalTo(outerDiameter)
    }

    // Content view
    contentView = UIView().then {
      $0.backgroundColor = .highlight
      $0.layer.cornerRadius = innerRadius
    }

    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(innerDiameter)
    }

    // Rank label
    rankLabel = UILabel().then {
      $0.text = "1"
      $0.textColor = .white
      $0.font = UIFont(name: "American Typewriter", size: 12)
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
      make.size.equalTo(innerDiameter - 1)
    }

  }

  func showLoading() {
    // Self
    isHidden = false

    // Content view
    contentView.backgroundColor = .emptyDark

    // Indicator
    indicator.startAnimating()

    // Rank Label
    rankLabel.isHidden = true
  }

  func showError() {
    // Self
    isHidden = false

    // Content view
    contentView.backgroundColor = .emptyDark

    // Indicator
    indicator.stopAnimating()

    // Rank Label
    rankLabel.isHidden = false
    rankLabel.text = "!"
  }

  func show(rank: Int) {
    jack.descendant("rank.didSet").assert(rank > 0, "invalid rank (\(rank)), should >= 1")

    // Hide for rank after 9
    if rank > 9 {
      isHidden = true
      return
    }

    // Badge
    isHidden = false

    // Content view
    contentView.backgroundColor = .highlight

    // Indicator
    indicator.stopAnimating()

    // Rank label
    rankLabel.isHidden = false
    rankLabel.text = rank.description
  }

}
