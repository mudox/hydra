import UIKit

import RxCocoa
import RxSwift

import MudoxKit

class PlaceholderView: View {

  // MARK: Subviews

  var imageView: UIImageView!

  var label: UILabel!

  var retryButton: UIButton!

  // MARK: - Setup View

  override func setupView() {
    backgroundColor = .clear
    clipsToBounds = false

    snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 240, height: 169))
    }

    setupImageView()
    setupLabel()
    setupRetryButton()
  }

  func setupImageView() {
    imageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit

      $0.layer.masksToBounds = false
    }

    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }

  func setupLabel() {
    label = UILabel().then {
      $0.text = ""
      $0.textColor = .emptyDark
      $0.font = .systemFont(ofSize: 14)
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }

    addSubview(label)
    label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(20)
    }
  }

  func setupRetryButton() {
    retryButton = UIButton(type: .custom).then {
      $0.setTitle("Retry", for: .normal)
      $0.titleLabel?.font = .text

      $0.clipsToBounds = true

      $0.setTitleColor(.emptyDark, for: .normal)
      $0.setBackgroundImage(nil, for: .normal)

      $0.setTitleColor(.white, for: .highlighted)
      $0.setBackgroundImage(UIImage.mdx.color(.emptyDark), for: .highlighted)

      $0.layer.cornerRadius = 3
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.emptyDark.cgColor
    }

    addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(label.snp.bottom).offset(20)
      make.size.equalTo(CGSize(width: 60, height: 17))
    }
  }

  func showGeneralError() {
    imageView.image = #imageLiteral(resourceName: "General Error Placeholder")
    label.text = "Oops"
    retryButton.isHidden = false
  }

  func showNetworkError() {
    imageView.image = #imageLiteral(resourceName: "Network Error Placeholder")
    label.text = "Network Error"
    retryButton.isHidden = false
  }

  func showEmpty() {
    imageView.image = #imageLiteral(resourceName: "Empty Placeholder")
    label.text = "Empty"
    retryButton.isHidden = true
  }

}
