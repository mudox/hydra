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

  var imageIndex: Int? {
    didSet {
      if let index = imageIndex {
        imageView.image = UIImage(named: "blurred-bg-\(index)")
      } else {
        imageView.image = nil
      }
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
    setupBadge(hasShadow: false)
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
      // Shape
      $0.cornerRadius = 6
      $0.masksToBounds = false

      // Shadow
      $0.shadowOffset = UI.shadowOffset
      $0.shadowRadius = UI.shadowRadius
      $0.shadowPath = UIBezierPath(roundedRect: $0.bounds, cornerRadius: 6).cgPath

      // Rasterization somehow blur all content above
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

  func setupBadge(hasShadow: Bool) {
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

    let views = [starsIcon, starsLabel!]
    let stackView = UIStackView(arrangedSubviews: views).then {
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

    gainedStarsLabel = UILabel().then {
      $0.text = "283"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .right
    }

    let views = [gainedStarsLabel!, gainedStarsIcon]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(margin)
    }

  }

  func setupBottomRightCorner() {
    let forksIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Fork Icon")
    }

    forksLabel = UILabel().then {
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .right
    }

    let views = [forksLabel!, forksIcon]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 2
    }

    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(margin)
      make.trailing.equalToSuperview().inset(margin + 1)
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

    let views = [languageColorView!, languageLabel!]
    let stackView = UIStackView(arrangedSubviews: views).then {
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

  // MARK: - Show States

  var isLoading = true

  func showState(_ state: TrendState) {
    switch state {
    case .loadingRepository:
      isLoading = true
      showLoading()
    case let .repository(repository, rank: rank):
      isLoading = false
      show(repository: repository, rank: rank)
    default:
      jack.failure("can not show this kind of state: \(state)")
    }
  }

  func showLoading() {
    // Hide shadows
    layer.shadowOpacity = 0

    // 4 corners
    starsLabel.text = ""
    gainedStarsLabel.text = ""
    forksLabel.text = ""
    languageLabel.text = ""
    languageColorView.backgroundColor = .white

    // Title and author
    repositoryLabel.text = ""
    ownerLabel.textColor = .lightGray
    ownerLabel.text = "Loading"

    backgroundColor = .groupTableViewBackground

    // Rank badge
    badge.showLoading()
  }

  func show(repository: Trending.Repository, rank: Int) {
    // Show shadows
    layer.shadowOpacity = UI.shadowOpacity

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
    ownerLabel.textColor = .white
    ownerLabel.text = repository.owner

    // Rank badge
    badge.showRank(rank)
  }

}
