import UIKit

import RxCocoa
import RxSwift

import SnapKit

import GitHub

class TrendRepositoryCell: UICollectionViewCell {

  // MARK: - Subviews

  fileprivate var imageView: UIImageView!
  fileprivate var repoLabel: UILabel!
  fileprivate var ownerLabel: UILabel!
  fileprivate var badge: TrendRankBadge!

  fileprivate var starsLabel: UILabel!
  fileprivate var gainedStarsLabel: UILabel!
  fileprivate var forksLabel: UILabel!
  fileprivate var contributorsView: ContributorsView!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupShadow()
    setupImageView()
    setupBadge()
    setupLabels()
    setupCorners()
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
    imageView = UIImageView(image: UIImage(named: "1.jpg")).then {
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
    repoLabel = UILabel().then {
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

    contentView.addSubview(repoLabel)
    repoLabel.snp.makeConstraints { make in
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
      make.top.equalTo(repoLabel.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(10)
    }

  }

  func setupCorners() {
    let margin = 8
    // Top left - stars
    starsLabel = UILabel().then {
      $0.text = "1383"
      $0.textColor = .white
      $0.font = .systemFont(ofSize: 10)
      $0.textAlignment = .left
    }

    contentView.addSubview(starsLabel)
    starsLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().inset(margin)
    }

    let starsIcon = UIImageView().then {
      $0.image = #imageLiteral(resourceName: "Stars Icon")
    }

    contentView.addSubview(starsIcon)
    starsIcon.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(margin)
      make.leading.equalTo(starsLabel.snp.trailing).offset(1)
    }

    // Top right - gained stars

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

    // Bottom right - gained stars
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

    // Bottom left - contributors wall
    contributorsView = ContributorsView()
    contentView.addSubview(contributorsView)
    contributorsView.snp.makeConstraints { make in
     make.leading.bottom.equalToSuperview().inset(margin)
    }
  }

}

// MARK: - TrendRepositoryCell.rx.repository

extension Reactive where Base: TrendRepositoryCell {

  var repository: Binder<GitHub.Trending.Repository> {
    return Binder(base) { cell, repo in
      cell.starsLabel.text = repo.starsCount.description
      cell.gainedStarsLabel.text = repo.gainedStarsCount.description

      if let count = repo.forksCount {
        cell.forksLabel.isHidden = false
        cell.forksLabel.text = count.description
      } else {
        cell.forksLabel.isHidden = true
      }

      cell.repoLabel.text = repo.name
      cell.ownerLabel.text = repo.owner
    }
  }

}
