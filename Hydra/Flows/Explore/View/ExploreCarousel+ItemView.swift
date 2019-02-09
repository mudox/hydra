import UIKit

import Then

import RxCocoa
import RxSwift

import JacKit
import class MudoxKit.View

import iCarousel
import SnapKit

import Kingfisher

private let jack = Jack().set(format: .short).set(level: .debug)

extension ExploreCarousel {

  class ItemView: View {

    let logoSize: CGFloat = 44

    var logoView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var stackView: UIStackView!

    override func setupView() {
      backgroundColor = .bgLight

      layer.do {
        $0.cornerRadius = 6
      }

      // Auto layout does work in iCarousel
      bounds = CGRect(
        origin: .zero,
        size: .init(width: 200, height: 140)
      )

      setupLogoView()
      setupTitleLabel()
      setupDescriptionLabel()
      setupStackView()
    }

    func setupLogoView() {
      logoView = UIImageView().then {
        $0.contentMode = .center

        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true

        $0.tintColor = .emptyDark
      }

      logoView.snp.makeConstraints { make in
        make.size.equalTo(logoSize)
      }
    }

    func setupTitleLabel() {
      titleLabel = UILabel().then {
        $0.textColor = .dark
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

    func setupDescriptionLabel() {
      descriptionLabel = UILabel().then {
        $0.textColor = .light
        $0.font = .text
        $0.textAlignment = .center

        // Auto shrink
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingTail

        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
        $0.allowsDefaultTighteningForTruncation = true
      }
    }

    func setupStackView() {
      let views: [UIView] = [logoView, titleLabel, descriptionLabel]
      stackView = UIStackView(arrangedSubviews: views).then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 10
      }

      addSubview(stackView)
      stackView.snp.makeConstraints { make in
        make.top.equalToSuperview().inset(9)
        make.leading.trailing.equalToSuperview().inset(10)
      }
    }

    func show(item: ExploreModel.Item) {
      showLogo(atLocalURL: item.logoLocalURL)

      titleLabel.text = item.title
      descriptionLabel.text = item.summary
    }

    var imageTask: DownloadTask?

    func showLogo(atLocalURL url: URL?) {
      let placeholderImage = #imageLiteral(resourceName: "Explore Carousel Logo Placeholder.pdf")
      if let url = url {
        let provider = LocalFileImageDataProvider(fileURL: url)
        let processor =
          DownsamplingImageProcessor(size: .init(width: logoSize, height: logoSize))
          >> RoundCornerImageProcessor(cornerRadius: 6)
        let options: KingfisherOptionsInfo = [
          .processor(processor),
          .scaleFactor(UIScreen.main.scale),
          .transition(.fade(1)),
          .cacheOriginalImage
        ]

        imageTask?.cancel()
        imageTask = logoView.kf.setImage(with: provider, placeholder: placeholderImage, options: options) {
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
