import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendRepositoryCell: TrendBaseCell {

  // MARK: - Subviews

  fileprivate var repositoryLabel: UILabel!
  fileprivate var ownerLabel: UILabel!

  fileprivate var starsLabel: UILabel!
  fileprivate var starsIcon: UIImageView!

  fileprivate var gainedStarsLabel: UILabel!
  fileprivate var gainedStarsIcon: UIImageView!

  fileprivate var forksLabel: UILabel!
  fileprivate var forksIcon: UIImageView!

  fileprivate var languageLabel: UILabel!
  fileprivate var languageBadge: UIView!

  // Currently unused
  fileprivate var tipLabel: UILabel!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupRepositoryLabel()
    setupOwnerLabel()
    setupTipLabel()

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

    contentView.addSubview(repositoryLabel)
    repositoryLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-14)
      make.leading.trailing.equalToSuperview().inset(10)
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

    contentView.addSubview(ownerLabel)
    ownerLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(repositoryLabel.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(10)
    }
  }

  func setupTipLabel() {
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

    contentView.addSubview(tipLabel)
    tipLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
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
      make.top.leading.equalToSuperview().offset(UI.margin)
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
      make.top.trailing.equalToSuperview().inset(UI.margin)
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
      make.bottom.equalToSuperview().inset(UI.margin)
      make.trailing.equalToSuperview().inset(UI.margin + 1)
    }
  }

  func setupBottomLeftCorner() {
    languageBadge = UIView().then {
      $0.layer.cornerRadius = 5
      $0.layer.borderWidth = 0.7
      $0.layer.borderColor = UIColor.white.cgColor
      $0.backgroundColor = .clear
    }

    languageLabel = UILabel().then {
      $0.textColor = .dark
      $0.font = .callout
      $0.textAlignment = .left
    }

    let views: [UIView] = [languageBadge, languageLabel]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }
    languageBadge.snp.makeConstraints { make in
      make.size.equalTo(10)
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.bottom.equalToSuperview().inset(UI.margin)
    }
  }

  // MARK: - Show States

  func showState(_ state: TrendCellState) {
    switch state {
    case .loadingRepository:
      showLoading()
    case let .repository(repository, rank: rank):
      show(repository: repository, rank: rank)
    default:
      jack.function().failure("can not show this kind of state: \(state)")
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

    // Labels
    repositoryLabel.isHidden = true
    ownerLabel.isHidden = true
    tipLabel.do {
      $0.text = "Loading"
      $0.isHidden = false
    }
  }

  func show(repository: Trending.Repository, rank: Int) {
    show(rank: rank)

    // Corners
    starsLabel.text = repository.starsCount.description
    starsIcon.tintColor = .dark

    gainedStarsLabel.text = repository.gainedStarsCount.description
    gainedStarsIcon.tintColor = .dark

    // Language
    if let language = repository.language {
      languageLabel.text = language.name

      if let color = UIColor(hexString: language.color) {
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

    // Center labels
    repositoryLabel.do {
      $0.isHidden = false
      $0.text = repository.name
    }
    ownerLabel.do {
      $0.isHidden = false
      $0.text = repository.owner
    }
    tipLabel.do {
      $0.isHidden = true
    }
  }

}
