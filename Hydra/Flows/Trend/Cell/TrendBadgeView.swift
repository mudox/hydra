import UIKit

import RxCocoa
import RxSwift

import NVActivityIndicatorView
import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

extension TrendCardCell {

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
    let indicator = NVActivityIndicatorView(frame: .zero, type: .ballScaleRippleMultiple, color: .emptyDark)
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

      setupRankLabel()
      setupIndicator()
      setupRetryButton()
    }

    func setupRankLabel() {
      rankLabel.do {
        $0.text = "1"
        $0.textColor = .white
        $0.font = UIFont(name: "American Typewriter", size: 12)
        $0.textAlignment = .center

        $0.layer.cornerRadius = innerRadius
        $0.layer.masksToBounds = true
      }

      addSubview(rankLabel)
      rankLabel.snp.makeConstraints { make in
        make.size.equalTo(innerDiameter)
        make.center.equalTo(self)
      }
    }

    func setupIndicator() {
      addSubview(indicator)
      indicator.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.size.equalTo(innerDiameter)
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

      // Indicator
      indicator.startAnimating()

      // Rank label
      rankLabel.isHidden = true

      // Retry button
      retryButton.isHidden = true
    }

    func showError() {
      // Self
      isHidden = false
      snp.updateConstraints { make in
        make.size.equalTo(CGSize(width: errorOuterWidth, height: outerDiameter))
      }

      // Indicator
      indicator.stopAnimating()

      // Rank label
      rankLabel.isHidden = true

      // Retry button
      retryButton.isHidden = false
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

      // Indicator
      indicator.stopAnimating()

      // Rank label
      rankLabel.do {
        $0.isHidden = false
        $0.text = rank.description
        $0.backgroundColor = color
      }

      // Retry button
      retryButton.isHidden = true
    }

  }

}
