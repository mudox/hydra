import UIKit

import Kingfisher
import SnapKit
import Then

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short).set(level: .debug)

extension ExploreController {

  class Cell: CollectionCell {

    // MARK: Metrics

    let logoSize = CGSize(width: 40, height: 40)
    let insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    let logoRightGap = 12
    let titleBottomGap = 4

    // MARK: - Subviews

    var logoView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!

    override func setupView() {
      backgroundColor = .bgLight

      layer.cornerRadius = 6

      contentView.snp.makeConstraints { make in
        make.width.equalTo(The.screen.bounds.width - 8 * 2)
      }

      setupLogoView()
      setupTitleLabel()
      setupDescriptionLabel()
    }

    func setupLogoView() {
      logoView = UIImageView().then {
        $0.contentMode = .center

        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true

        $0.tintColor = .emptyDark
      }

      contentView.addSubview(logoView)
      logoView.snp.makeConstraints { make in
        make.size.equalTo(logoSize)
        make.leading.equalToSuperview().inset(insets)
        make.centerY.equalToSuperview()
      }
    }

    func setupTitleLabel() {
      titleLabel = UILabel().then {
        $0.textColor = .dark
        $0.font = .title
        $0.textAlignment = .left

        // Auto shrink
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail

        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
        $0.allowsDefaultTighteningForTruncation = true
      }

      contentView.addSubview(titleLabel)
      titleLabel.snp.makeConstraints { make in
        make.top.trailing.equalToSuperview().inset(insets)
        make.leading.equalTo(logoView.snp.trailing).offset(logoRightGap)
      }
    }

    func setupDescriptionLabel() {
      descriptionLabel = UILabel().then {
        $0.textColor = .light
        $0.font = .text
        $0.textAlignment = .justified

        // Auto shrink
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingTail

        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
        $0.allowsDefaultTighteningForTruncation = true
      }

      contentView.addSubview(descriptionLabel)
      descriptionLabel.snp.makeConstraints { make in
        make.top.equalTo(titleLabel.snp.bottom).offset(titleBottomGap)
        make.leading.trailing.equalTo(titleLabel)
        make.bottom.equalToSuperview().inset(insets)
      }
    }

    func show(_ item: ExploreModel.Item) {
      showLogo(atLocalURL: item.logoLocalURL)

      titleLabel.text = item.title
      descriptionLabel.text = item.summary
    }

    func showLogo(atLocalURL url: URL?) {
      let placeholderImage = #imageLiteral(resourceName: "Explore Carousel Logo Placeholder.pdf")
      if let url = url {
        let provider = LocalFileImageDataProvider(fileURL: url)
        let processor =
          DownsamplingImageProcessor(size: logoSize)
          >> RoundCornerImageProcessor(cornerRadius: 6)
        let options: KingfisherOptionsInfo = [
          .processor(processor),
          .scaleFactor(UIScreen.main.scale),
          .transition(.fade(1)),
          .cacheOriginalImage
        ]

        logoView.kf.setImage(with: provider, placeholder: placeholderImage, options: options) {
          result in
          switch result {
          case .success:
            jack.func().verbose("Succeeded to show image: \(url.lastPathComponent)")
          case let .failure(error):
            jack.func().error("Error showing image: \(error.localizedDescription)")
          }
        }
      } else {
        logoView.image = #imageLiteral(resourceName: "Explore Carousel Logo Placeholder")
      }
    }

  }

}
