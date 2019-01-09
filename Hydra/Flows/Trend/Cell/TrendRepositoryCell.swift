import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

// swiftlint:disable:next type_body_length
class TrendRepositoryCell: TrendItemCell {

  static let id = "\(type(of: self))"

  static let size = CGSize(width: 270, height: 170)

  // MARK: - Subviews

  private var repositoryLabel: UILabel!
  private var ownerLabel: UILabel!
  private var centerStackView: UIStackView!

  private var starsLabel: UILabel!
  private var starsIcon: UIImageView!

  private var gainedStarsLabel: UILabel!
  private var gainedStarsIcon: UIImageView!

  private var forksLabel: UILabel!
  private var forksIcon: UIImageView!

  private var languageLabel: UILabel!
  private var languageBadge: UIView!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    snp.makeConstraints { make in
      make.size.equalTo(TrendRepositoryCell.size)
    }

    // Center
    setupRepositoryLabel()
    setupOwnerLabel()

    setupContentStackView()

    // Corners
    setupTopLeftCorner()
    setupTopRightCorner()
    setupBottomRightCorner()
    setupBottomLeftCorner()
  }

  func setupRepositoryLabel() {
    repositoryLabel = UILabel().then {
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
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupContentStackView() {
    let views: [UIView] = [repositoryLabel, ownerLabel]
    centerStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 6
    }

    contentView.addSubview(centerStackView)
    centerStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.lessThanOrEqualToSuperview().inset(CGFloat.margin)
    }
  }

  func setupTopLeftCorner() {
    starsLabel = UILabel().then {
      $0.text = "1383"
      $0.textColor = .dark
      $0.font = .callout
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
  
  func show(state: LoadingState<Trending.Repository>, context: Trend.Item, at: Int) {
    
  }

  func show(state: LoadingState<(Int, Trending.Repository)>) {
    switch state {
    case .loading:
      showLoading()
    case let .value(value):
      show(repository: value.1, rank: value.0)
    case let .error(error):
      show(error: error)
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
    centerStackView.isHidden = false
    repositoryLabel.do {
      $0.text = "XXXXXXXXXX"
      $0.textColor = .emptyDark
      $0.backgroundColor = .emptyDark
      $0.transform = .init(scaleX: 0.6, y: 0.65)
      $0.layer.cornerRadius = .cornerRadius
      $0.layer.masksToBounds = true
    }
    ownerLabel.do {
      $0.text = "XXXXXXX"
      $0.textColor = .emptyDark
      $0.backgroundColor = .emptyDark
      $0.transform = .init(scaleX: 0.6, y: 0.7)
      $0.transform = $0.transform.translatedBy(x: 0, y: -5)
      $0.layer.cornerRadius = .cornerRadius
      $0.layer.masksToBounds = true
    }
  }

  override func show(error: Error, period: Trending.Period) {
    super.show(error: error, period: period)

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

    // Badge
    badge.showError()
  }

  func show(repository: Trending.Repository, rank: Int) {
    show(rank: rank, color: repository.language?.color ?? .light)

    // Stars
    starsLabel.text = repository.starsCount.description
    starsIcon.tintColor = .dark

    // Gained Stars
    if let count = repository.gainedStarsCount {
      gainedStarsLabel.isHidden = false
      gainedStarsIcon.isHidden = false

      gainedStarsLabel.text = count.description
      gainedStarsIcon.tintColor = .dark
    } else {
      gainedStarsLabel.isHidden = true
      gainedStarsIcon.isHidden = true
    }

    // Language
    if let language = repository.language {
      languageLabel.text = language.name

      if let color = language.color {
        languageBadge.isHidden = false
        languageBadge.backgroundColor = color
      } else {
        languageBadge.isHidden = true
      }
    }

    // Forks count
    if let count = repository.forksCount {
      forksLabel.isHidden = false
      forksLabel.text = count.description
      forksIcon.tintColor = .dark
    } else {
      forksLabel.isHidden = true
    }

    // Center
    centerStackView.isHidden = false
    repositoryLabel.do {
      $0.text = repository.name
      $0.textColor = .dark
      $0.backgroundColor = .clear
      $0.transform = .identity
      $0.layer.cornerRadius = 0
    }
    ownerLabel.do {
      $0.text = repository.owner
      $0.textColor = .dark
      $0.backgroundColor = .clear
      $0.transform = .identity
      $0.layer.cornerRadius = 0
    }
  }

}
