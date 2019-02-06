import UIKit

import RxCocoa
import RxSwift

import NVActivityIndicatorView

import MudoxKit

class LoadingStatesView: View {

  // MARK: Subviews

  var loadingView: NVActivityIndicatorView!

  var imageView: UIImageView!

  var label: UILabel!

  var retryButton: UIButton!

  // MARK: - View

  override func setupView() {
    aid = .placeholderView

    backgroundColor = .clear
    clipsToBounds = false

    snp.makeConstraints { make in
      make.size.greaterThanOrEqualTo(CGSize(width: 240, height: 169))
    }

    setupLoadingView()
    setupImageView()
    setupLabel()
    setupRetryButton()
  }

  func setupLoadingView() {
    loadingView = NVActivityIndicatorView(
      frame: .zero,
      type: .orbit,
      color: .brand
    )

    addSubview(loadingView)
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(50)
    }
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

  // MARK: - Binding

  static let retry = PublishRelay<Void>()

  override func setupBinding() {
    retryButton.rx.tap
      .bind(to: type(of: self).retry)
      .disposed(by: bag)
  }

  // MARK: - Show State

  func showGeneralError(
    title: String = "Oops",
    buttonTitle: String? = "Retry"
  )
  {
    isHidden = false

    loadingView.stopAnimating()
    imageView.do {
      $0.isHidden = false
      $0.image = #imageLiteral(resourceName: "Network Error Placeholder")
    }
    label.do {
      $0.isHidden = false
      $0.text = title
    }
    if let buttonTitle = buttonTitle {
      retryButton.isHidden = false
      retryButton.setTitle(buttonTitle, for: .normal)
    } else {
      retryButton.isHidden = true
    }
  }

  func showNetworkError(
    title: String = "Network Error",
    buttonTitle: String? = "Retry"
  )
  {
    isHidden = false

    loadingView.stopAnimating()
    imageView.do {
      $0.isHidden = false
      $0.image = #imageLiteral(resourceName: "Network Error Placeholder")
    }
    label.do {
      $0.isHidden = false
      $0.text = title
    }
    if let buttonTitle = buttonTitle {
      retryButton.isHidden = false
      retryButton.setTitle(buttonTitle, for: .normal)
    } else {
      retryButton.isHidden = true
    }
  }

  func showEmptyData(
    title: String = "Empty",
    buttonTitle: String? = nil
  )
  {
    isHidden = false

    loadingView.stopAnimating()
    imageView.do {
      $0.isHidden = false
      $0.image = #imageLiteral(resourceName: "Empty Placeholder")
    }
    label.do {
      $0.isHidden = false
      $0.text = title
    }
    if let buttonTitle = buttonTitle {
      retryButton.isHidden = false
      retryButton.setTitle(buttonTitle, for: .normal)
    } else {
      retryButton.isHidden = true
    }
  }

  func showLoading() {
    isHidden = false

    loadingView.startAnimating()
    imageView.isHidden = true
    label.isHidden = true
    retryButton.isHidden = true
  }

}
