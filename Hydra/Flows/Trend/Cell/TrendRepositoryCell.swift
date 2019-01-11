import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

// swiftlint:disable:next type_body_length
class TrendRepositoryCell: TrendCardCell {

  static let id = "\(type(of: self))"

  // MARK: - Subviews

  private var nameLabel: UILabel!
  private var ownerLabel: UILabel!
  private var centerInnerStackView: UIStackView!

  private var placeholder: UIStackView!

  private var summaryLabel: UILabel!
  private var centerStackView: UIStackView!

  private var starsLabel: UILabel!
  private var starsIcon: UIImageView!

  private var gainedStarsLabel: UILabel!
  private var gainedStarsIcon: UIImageView!

  private var forksLabel: UILabel!
  private var forksIcon: UIImageView!

  private var languageLabel: UILabel!
  private var languageBadge: UIView!

  // MARK: - Setup View

  override init(frame: CGRect) {
    super.init(frame: frame)

    snp.makeConstraints { make in
      make.size.equalTo(TrendRepositoryCell.size)
    }

    // Center
    setupNameLabel()
    setupOwnerLabel()
    setupSummaryLabel()
    setupCenterStackView()

    setupPlaceholder()

    // Corners
    setupTopLeftCorner()
    setupTopRightCorner()
    setupBottomRightCorner()
    setupBottomLeftCorner()
  }

  func setupNameLabel() {
    nameLabel = UILabel().then {
      $0.text = "Repository Name"
      $0.textColor = .dark
      $0.font = .title
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 2
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupOwnerLabel() {
    ownerLabel = UILabel().then {
      $0.text = "Owner Name"
      $0.textColor = .dark
      $0.font = .text
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.8
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupPlaceholder() {

    let nameLine = UIView().then {
      $0.backgroundColor = .emptyDark
      $0.layer.cornerRadius = 3
      $0.isUserInteractionEnabled = false
      $0.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: 110, height: 14))
      }
    }

    let ownerLine = UIView().then {
      $0.backgroundColor = .emptyDark
      $0.layer.cornerRadius = 3
      $0.isUserInteractionEnabled = false
      $0.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: 55, height: 11))
      }
    }

    let summaryLines = (0..<3).map { index in
      return UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.833925426, green: 0.833925426, blue: 0.833925426, alpha: 1)
        $0.layer.cornerRadius = 2
        $0.isUserInteractionEnabled = false
        $0.snp.makeConstraints { make in
          make.size.equalTo(CGSize(width: (index == 2) ? 133 : 190, height: 10))
        }
      }
    }

    var views: [UIView] = [nameLine, ownerLine]
    let topStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 10
    }

    let bottomStackView = UIStackView(arrangedSubviews: summaryLines).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 5
    }

    views = [topStackView, bottomStackView]
    placeholder = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 15
    }

    contentView.addSubview(placeholder)
    placeholder.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  func setupSummaryLabel() {
    summaryLabel = UILabel().then {
      $0.text = "Repository Description"
      $0.textColor = .light
      $0.font = .callout
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 5
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.8
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupCenterStackView() {
    var views: [UIView] = [nameLabel, ownerLabel]
    centerInnerStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 6
    }

    views = [centerInnerStackView, summaryLabel]
    centerStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 10
    }

    contentView.addSubview(centerStackView)
    centerStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.lessThanOrEqualToSuperview().inset(CGFloat.margin * 2)
    }
  }

  func setupTopLeftCorner() {
    starsLabel = UILabel().then {
      $0.text = "1383"
      $0.textColor = .dark
      $0.font = .text
      $0.textAlignment = .left
    }

    starsIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Stars Icon")
    }

    let views: [UIView] = [starsIcon, starsLabel]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().offset(CGFloat.margin)
    }

  }

  func setupTopRightCorner() {
    gainedStarsIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Gained Stars Icon")
    }

    gainedStarsLabel = UILabel().then {
      $0.text = "283"
      $0.textColor = .dark
      $0.font = .callout
      $0.textAlignment = .right
    }

    let views: [UIView] = [gainedStarsLabel!, gainedStarsIcon]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(CGFloat.margin)
    }

  }

  func setupBottomRightCorner() {
    forksIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Fork Icon")
    }

    forksLabel = UILabel().then {
      $0.textColor = .dark
      $0.font = .callout
      $0.textAlignment = .right
    }

    let views: [UIView] = [forksLabel!, forksIcon]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(CGFloat.margin)
      make.trailing.equalToSuperview().inset(CGFloat.margin + 1)
    }
  }

  func setupBottomLeftCorner() {
    let badgeDiameter: CGFloat = 9

    languageBadge = UIView().then {
      $0.layer.cornerRadius = badgeDiameter / 2
      $0.backgroundColor = .clear

      $0.snp.makeConstraints { make in
        make.size.equalTo(badgeDiameter)
      }
    }

    languageLabel = UILabel().then {
      $0.textColor = .dark
      $0.font = .callout
      $0.textAlignment = .left
      $0.lineBreakMode = .byTruncatingTail
    }

    let views: [UIView] = [languageBadge, languageLabel]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 3
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.bottom.equalToSuperview().inset(CGFloat.margin)
      make.trailing.equalTo(badge.snp.leading)
    }
  }

  // MARK: - Show States

  func show(state: LoadingState<Trending.Repository>, context: Trend.Context, at index: Int) {
    switch state {
    case .loading:
      showLoading()
    case let .value(repo):
      show(repository: repo, rank: index + 1)
    case let .error(error):
      show(error: error, context: context)
    }
  }

  override func showLoading() {
    super.showLoading()

    // Corners
    starsLabel.text = ""
    starsIcon.tintColor = .white

    gainedStarsLabel.text = ""
    gainedStarsIcon.tintColor = .white

    forksLabel.text = ""
    forksIcon.tintColor = .white

    languageLabel.text = ""
    languageBadge.backgroundColor = .white

    // Center
    centerStackView.isHidden = true
    placeholder.isHidden = false
  }

  override func show(error: Error, context: Trend.Context) {
    super.show(error: error, context: context)

    // Corners
    starsLabel.text = ""
    starsIcon.tintColor = .white

    gainedStarsLabel.text = ""
    gainedStarsIcon.tintColor = .white

    forksLabel.text = ""
    forksIcon.tintColor = .white

    languageLabel.text = ""
    languageBadge.backgroundColor = .white

    // Center
    centerStackView.isHidden = true
    placeholder.isHidden = true

    // Badge
    badge.showError()
  }

  func show(repository: Trending.Repository, rank: Int) {
    show(rank: rank, color: repository.language?.color ?? .light)

    // Stars corner
    starsLabel.text = repository.starsCount.description
    starsIcon.tintColor = .dark

    // Gained stars corner
    if let count = repository.gainedStarsCount {
      gainedStarsLabel.isHidden = false
      gainedStarsIcon.isHidden = false

      gainedStarsLabel.text = count.description
      gainedStarsIcon.tintColor = .dark
    } else {
      gainedStarsLabel.isHidden = true
      gainedStarsIcon.isHidden = true
    }

    // Language corner
    if let language = repository.language {
      languageLabel.text = language.name

      if let color = language.color {
        languageBadge.isHidden = false
        languageBadge.backgroundColor = color
      } else {
        languageBadge.isHidden = true
      }
    }

    // Forks corner
    if let count = repository.forksCount {
      forksLabel.isHidden = false
      forksLabel.text = count.description
      forksIcon.tintColor = .dark
    } else {
      forksLabel.isHidden = true
    }

    // Center
    centerStackView.isHidden = false
    placeholder.isHidden = true
  }

}
