import UIKit

import RxCocoa
import RxSwift

import SkeletonView
import SnapKit

import Kingfisher

import GitHub
import JacKit

private let jack = Jack().set(format: .short)

class TrendDeveloperCell: TrendCardCell {

  static let id = "\(type(of: self))"

  // MARK: - Subviews

  private var avatarView: UIImageView!
  private var nameLabel: UILabel!
  private var repositoryLabel: UILabel!
  private var centerStackView: UIStackView!

  private var skeleton: UIStackView!

  // MARK: - Setup View

  override init(frame: CGRect) {
    super.init(frame: frame)

    snp.makeConstraints { make in
      make.size.equalTo(TrendDeveloperCell.size)
    }

    setupAvatarView()
    setupNameLabel()
    setupRepositoryLabel()
    setupCenterStackView()

    setupSkeleton()
  }

  let avatarDiameter: CGFloat = 50
  let centerInsets = UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20)
  let gapBelowAvatarView: CGFloat = 20
  let gapBelowNameLabel: CGFloat = 8

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
      $0.setCustomSpacing(gapBelowAvatarView, after: avatarView)
      $0.setCustomSpacing(gapBelowNameLabel, after: nameLabel)
    }

    contentView.addSubview(centerStackView)
    centerStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.lessThanOrEqualToSuperview().inset(centerInsets)
    }
  }

  func setupSkeleton() {
    func setup(_ view: UIView, cornerRadius: CGFloat) {
      view.isSkeletonable = true
      view.layer.cornerRadius = cornerRadius
      view.layer.masksToBounds = true
    }

    let avatar = UIView().then {
      setup($0, cornerRadius: 25)
      $0.snp.makeConstraints { make in
        make.size.equalTo(avatarDiameter)
      }
    }

    let nameLine = UIView().then {
      setup($0, cornerRadius: 3)
      $0.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: 110, height: 14))
      }
    }

    let repoLine = UIView().then {
      setup($0, cornerRadius: 2)
      $0.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: 90, height: 11))
      }
    }

    let views: [UIView] = [avatar, nameLine, repoLine]
    skeleton = UIStackView(arrangedSubviews: views).then {
      $0.isSkeletonable = true
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.setCustomSpacing(gapBelowAvatarView, after: avatar)
      $0.setCustomSpacing(gapBelowNameLabel, after: nameLine)
    }
    contentView.addSubview(skeleton)
    skeleton.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  // MARK: - Show States

  func show(state: LoadingState<Trending.Developer>, context: Trend.Context, at index: Int) {
    switch state {
    case .loading:
      showLoading()
    case let .value(developer):
      show(developer: developer, rank: index + 1)
    case let .error(error):
      show(error: error, context: context)
    }
  }

  override func showLoading() {
    super.showLoading()

    centerStackView.isHidden = true
    skeleton.do {
      $0.isHidden = false
      let gradient = SkeletonGradient(baseColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
      let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
      $0.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }
  }

  func show(developer: Trending.Developer, rank: Int) {
    show(rank: rank, color: .brand)

    centerStackView.isHidden = false
    skeleton.hideSkeleton()

    avatarImageTask = avatarView.kf.setImage(
      with: developer.avatarURL,
      options: [.transition(.fade(0.2))]
    )

    nameLabel.text = developer.name
    repositoryLabel.text = developer.repositoryName
  }

  override func show(error: Error, context: Trend.Context) {
    super.show(error: error, context: context)

    // Avatar View
    avatarView.image = [#imageLiteral(resourceName: "Male Avatar"), #imageLiteral(resourceName: "Femail Avatar")].randomElement()!
    avatarView.tintColor = .emptyDark

    // Center
    centerStackView.isHidden = true
    skeleton.hideSkeleton()
  }

  // MARK: - Image Task

  var avatarImageTask = RetrieveImageTask.empty

  override func prepareForReuse() {
    super.prepareForReuse()

    avatarImageTask.cancel()
    avatarView.image = nil
  }

}
