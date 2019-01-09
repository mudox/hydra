import UIKit

import RxCocoa
import RxSwift

import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendDeveloperCell: TrendItemCell {

  static let id = "\(type(of: self))"

  static let size = CGSize(width: 270, height: 170)

  // MARK: - Subviews

  private var avatarView: UIImageView!
  private var nameLabel: UILabel!
  private var repositoryLabel: UILabel!
  private var centerStackView: UIStackView!

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)

    snp.makeConstraints { make in
      make.size.equalTo(TrendDeveloperCell.size)
    }

    setupAvatarView()
    setupNameLabel()
    setupRepositoryLabel()
    setupCenterStackView()

  }

  let avatarDiameter: CGFloat = 32

  func setupAvatarView() {
    avatarView = UIImageView().then {
      $0.contentMode = .scaleAspectFill

      $0.layer.cornerRadius = avatarDiameter / 2
      $0.layer.masksToBounds = true
    }

    avatarView.snp.makeConstraints { make in
      make.size.equalTo(avatarDiameter)
    }
  }

  func setupNameLabel() {
    nameLabel = UILabel().then {
      $0.text = "Developer Name"
      $0.textColor = .white
      $0.font = .title
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
  }

  func setupRepositoryLabel() {
    repositoryLabel = UILabel().then {
      $0.text = "Repo Name"
      $0.textColor = .white
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

  func setupCenterStackView() {
    let views: [UIView] = [avatarView, nameLabel, repositoryLabel]
    centerStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 6
    }

    contentView.addSubview(centerStackView)
    centerStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.lessThanOrEqualToSuperview().inset(UIEdgeInsets.trend)
    }
  }

  // MARK: - Show States

  func show(state: LoadingState<(Trending.Developer, Int)>, period: Trending.Period) {
    switch state {
    case .loading:
      showLoading()
    case let .value(value):
      show(developer: value.0, rank: value.1)
    case let .error(error):
      show(error: error, period: period)
    }
  }

  override func showLoading() {
    super.showLoading()

    // Avatar View
    avatarView.image = [#imageLiteral(resourceName: "Male Avatar"), #imageLiteral(resourceName: "Femail Avatar")].randomElement()!
    avatarView.tintColor = .emptyDark

    // Labels
    nameLabel.do {
      $0.textColor = .emptyDark
      $0.backgroundColor = .emptyDark
      $0.transform = .init(scaleX: 0.6, y: 0.6)
      $0.layer.cornerRadius = 2
      $0.layer.masksToBounds = true
    }
    repositoryLabel.do {
      $0.textColor = .emptyDark
      $0.backgroundColor = .emptyDark
      $0.transform = .init(scaleX: 0.6, y: 0.7)
      $0.transform = $0.transform.translatedBy(x: 0, y: -5)
      $0.layer.cornerRadius = 2
      $0.layer.masksToBounds = true
    }
  }

  override func show(error: Error, period: Trending.Period) {
    super.show(error: error, period: period)

    // Avatar View
    avatarView.image = [#imageLiteral(resourceName: "Male Avatar"), #imageLiteral(resourceName: "Femail Avatar")].randomElement()!
    avatarView.tintColor = .emptyDark

    // Center
    centerStackView.isHidden = true
  }

  func show(developer: Trending.Developer, rank: Int) {
    show(rank: rank, color: .brand)

    // Avatar View
    avatarImageTask = avatarView.kf.setImage(
      with: developer.avatarURL,
      options: [.transition(.fade(0.2))]
    )

    // Developer name and repository name
    centerStackView.isHidden = false
    nameLabel.do {
      $0.text = developer.name
      $0.textColor = .dark
      $0.backgroundColor = .clear
      $0.transform = .identity
      $0.layer.cornerRadius = 0
    }
    repositoryLabel.do {
      $0.text = developer.repositoryName
      $0.textColor = .dark
      $0.backgroundColor = .clear
      $0.transform = .identity
      $0.layer.cornerRadius = 0
    }
  }

  // MARK: - Image Task

  var avatarImageTask = RetrieveImageTask.empty

  override func prepareForReuse() {
    super.prepareForReuse()

    avatarImageTask.cancel()
    avatarView.image = nil
  }

}
