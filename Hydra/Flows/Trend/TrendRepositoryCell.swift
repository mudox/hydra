import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendRepositoryCell: UICollectionViewCell {

  let margin = 8

  var imageIndex: Int = 0 {
    didSet {
      imageView.image = UIImage(named: "blurred-bg-\(imageIndex)")
    }
  }

  // MARK: - Subviews

  fileprivate var imageView: UIImageView!
  fileprivate var repositoryLabel: UILabel!
  fileprivate var ownerLabel: UILabel!
  fileprivate var badge: TrendRankBadge!

  fileprivate var starsLabel: UILabel!
  fileprivate var gainedStarsLabel: UILabel!
  fileprivate var forksLabel: UILabel!
  fileprivate var languageLabel: UILabel!
  fileprivate var languageColorView: UIView!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    tintColor = .white

    setupShadow()
    setupImageView()
    setupBadge()
    setupLabels()

    setupTopLeftCorner()
    setupTopRightCorner()
    setupBottomRightCorner()
    setupBottomLeftCorner()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use")
  }

  func setupShadow() {
    layer.do {
      $0.cornerRadius = 6
      $0.masksToBounds = false

      $0.shadowOffset = UI.shadowOffset
      $0.shadowOpacity = UI.shadowOpacity
      $0.shadowRadius = UI.shadowRadius
      $0.shadowPath = UIBezierPath(roundedRect: $0.bounds, cornerRadius: 6).cgPath

      // rasterization somehow blur all content above
      $0.shouldRasterize = false
    }
  }

  func setupImageView() {
    imageView = UIImageView().then {
      $0.contentMode = .scaleAspectFill

      $0.layer.cornerRadius = 6
      $0.layer.masksToBounds = true
    }

    contentView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
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

  func setupLabels() {
    // Repository name label
    repositoryLabel = UILabel().then {
      $0.text = "Repository Name"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 20, weight: .bold)
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
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

    // Repository owner name label
    ownerLabel = UILabel().then {
      $0.text = "Owner Name"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 14)
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

  func setupTopLeftCorner() {
    starsLabel = UILabel().then {
      $0.text = "1383"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .left
    }

    let starsIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Stars Icon")
    }

    let stackView = UIStackView(arrangedSubviews: [starsIcon, starsLabel]).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().offset(margin)
    }

  }

  func setupTopRightCorner() {
    let gainedStarsIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Gained Stars Icon")
    }

    contentView.addSubview(gainedStarsIcon)
    gainedStarsIcon.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(margin)
    }

    gainedStarsLabel = UILabel().then {
      $0.text = "283"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .right
    }

    contentView.addSubview(gainedStarsLabel)
    gainedStarsLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(margin)
      make.trailing.equalTo(gainedStarsIcon.snp.leading).offset(-1)
    }

  }

  func setupBottomRightCorner() {
    let forksIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Fork Icon")
    }

    contentView.addSubview(forksIcon)
    forksIcon.snp.makeConstraints { make in
      make.bottom.trailing.equalToSuperview().inset(margin)
    }

    forksLabel = UILabel().then {
      $0.text = "87"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .right
    }

    contentView.addSubview(forksLabel)
    forksLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(margin)
      make.trailing.equalTo(forksIcon.snp.leading).offset(-1)
    }
  }

  func setupBottomLeftCorner() {
    languageColorView = UIView().then {
      $0.layer.cornerRadius = 5
      $0.layer.borderWidth = 0.7
      $0.layer.borderColor = UIColor.white.cgColor
      $0.backgroundColor = .clear
    }

    languageLabel = UILabel().then {
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .left
    }

    let stackView = UIStackView(arrangedSubviews: [languageColorView, languageLabel]).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }
    languageColorView.snp.makeConstraints { make in
      make.size.equalTo(10)
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.bottom.equalToSuperview().inset(margin)
    }
  }

  func show(repository: Trending.Repository, rank: Int) {
    // Stars counts
    starsLabel.text = repository.starsCount.description
    gainedStarsLabel.text = repository.gainedStarsCount.description

    // Language color & name
    if let language = repository.language {
      languageLabel.text = language.name

      if let color = UIColor(hexString: language.color) {
        languageColorView.isHidden = false
        languageColorView.backgroundColor = color
      } else {
        languageColorView.isHidden = true
      }
    }

    // Forks count
    if let count = repository.forksCount {
      forksLabel.isHidden = false
      forksLabel.text = count.description
    } else {
      forksLabel.isHidden = true
    }

    // Title and author
    repositoryLabel.text = repository.name
    ownerLabel.text = repository.owner

    // Rank badge
    badge.rank = rank
  }

}
