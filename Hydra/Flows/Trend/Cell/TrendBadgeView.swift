import UIKit

import NVActivityIndicatorView
import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

extension TrendItemCell {

  class BadgeView: UIView {

    init() {
      super.init(frame: .zero)

      setupView()
    }

    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Metrics

    private let innerDiameter: CGFloat = 18
    private let borderWidth: CGFloat = 4

    private let errorOuterWidth: CGFloat = 48
    private var errorInnerWidth: CGFloat { return errorOuterWidth - (borderWidth * 2) }

    private var innerRadius: CGFloat { return innerDiameter / 2 }
    private var outerRadius: CGFloat { return innerRadius + borderWidth }
    private var outerDiameter: CGFloat { return outerRadius * 2 }

    // MARK: - Subviews

    let rankLabel = UILabel()
    let contentView = UIView()
    let indicator = NVActivityIndicatorView(frame: .zero, type: .ballScaleRippleMultiple, color: .white)
    let retryButton = UIButton(type: .custom)

    // MARK: - Setup View

    func setupView() {
      // Self to mimic border
      backgroundColor = .bgDark
      layer.cornerRadius = outerRadius

      // Fixed size
      snp.makeConstraints { make in
        make.size.equalTo(outerDiameter)
      }

      setupContentView()
      setupRankLabel()
      setupIndicator()
      setupRetryButton()
    }

    func setupContentView() {
      contentView.do {
        $0.backgroundColor = .brand
        $0.layer.cornerRadius = innerRadius
      }

      addSubview(contentView)
      contentView.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.size.equalTo(innerDiameter)
      }
    }

    func setupRankLabel() {
      rankLabel.do {
        $0.text = "1"
        $0.textColor = .white
        $0.font = UIFont(name: "American Typewriter", size: 12)
        $0.textAlignment = .center
      }

      addSubview(rankLabel)
      rankLabel.snp.makeConstraints { make in
        make.center.equalTo(self)
      }
    }

    func setupIndicator() {
      addSubview(indicator)
      indicator.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.size.equalTo(innerDiameter + 1)
      }

    }

    func setupRetryButton() {
      retryButton.do {
        $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .light)

        $0.setBackgroundImage(UIImage.mdx.color(.emptyDark), for: .normal)
        $0.setBackgroundImage(UIImage.mdx.color(.brand), for: .highlighted)

        $0.layer.cornerRadius = innerRadius
        $0.layer.masksToBounds = true
      }

      addSubview(retryButton)
      retryButton.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: 40, height: innerDiameter))
        make.center.equalToSuperview()
      }
    }

    // MARK: - Show

    func showLoading() {
      // Self
      isHidden = false
      snp.updateConstraints { make in
        make.size.equalTo(outerDiameter)
      }

      // Content view
      contentView.do {
        $0.isHidden = false
        $0.backgroundColor = .emptyDark
      }

      // Indicator
      indicator.startAnimating()

      // Other
      rankLabel.isHidden = true
      retryButton.isHidden = true
    }

    func showError() {
      // Self
      isHidden = false
      snp.updateConstraints { make in
        make.size.equalTo(CGSize(width: errorOuterWidth, height: outerDiameter))
      }

      // Content view
      contentView.isHidden = true

      // Indicator
      indicator.stopAnimating()

      // Rank Label
      rankLabel.isHidden = true
    }

    func show(rank: Int, color: UIColor) {
      jack.func().assert(rank > 0, "Invalid rank (\(rank)), should >= 1")

      // Self
      if rank > 9 {
        // Hide for rank after 9
        isHidden = true
        return
      } else {
        isHidden = false
      }

      snp.updateConstraints { make in
        make.size.equalTo(outerDiameter)
      }

      // Content view
      contentView.do {
        $0.isHidden = false
        $0.backgroundColor = color
      }

      // Rank label
      rankLabel.isHidden = false
      rankLabel.text = rank.description

      // Other
      indicator.stopAnimating()
      retryButton.isHidden = true
    }

  }

}
