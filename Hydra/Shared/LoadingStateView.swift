import UIKit

import RxCocoa
import RxSwift

import NVActivityIndicatorView

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

/// A view for showing special states like loading, error, no data.
///
/// Usage:
///
/// ```swift
/// loadingStateView = LoadingStateView()
///
/// view.addSubview(loadingStateView)
/// loadingStateView.snp.makeConstraints { make in
///   make.center.equalToSuperview()
/// }
/// ```
final class LoadingStateView: View {

  // MARK: Subviews

  // Loading stack view
  var loadingIndicator: NVActivityIndicatorView!
  var loadingLabel: UILabel!
  var loadingStackView: UIStackView!

  // Result stack view
  var imageView: UIImageView!
  var label: UILabel!
  var retryButton: UIButton!
  var resultStackView: UIStackView!

  // MARK: - View

  override func setupView() {
    aid = .loadingStateView

    isHidden = true

    backgroundColor = .clear
    clipsToBounds = false

    snp.makeConstraints { make in
      make.size.greaterThanOrEqualTo(CGSize(width: 240, height: 120))
        .priority(UILayoutPriority.defaultLow)
    }

    setupLoadingStackView()
    setupResultStackView()
  }

  func setupLoadingStackView() {
    loadingIndicator = NVActivityIndicatorView(
      frame: .zero,
      type: .ballScaleMultiple,
      color: .brand
    )

    loadingIndicator.snp.makeConstraints { make in
      make.size.equalTo(40)
    }

    loadingLabel = UILabel().then {
      $0.text = ""
      $0.textColor = .emptyDark
      $0.font = .systemFont(ofSize: 12)
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.8
      $0.allowsDefaultTighteningForTruncation = true
    }

    let views: [UIView] = [loadingIndicator, loadingLabel]
    loadingStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 10
    }

    addSubview(loadingStackView)
    loadingStackView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }

  func setupResultStackView() {
    imageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit
      $0.layer.masksToBounds = false
    }

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

    retryButton.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 60, height: 17))
    }

    let views: [UIView] = [imageView, label, retryButton]
    resultStackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .vertical
      $0.distribution = .fill
      $0.alignment = .center
      $0.spacing = 10
    }

    addSubview(resultStackView)
    resultStackView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }

  // MARK: - Show State

  private enum Mode {
    case showingLoading
    case showingResult
    case hidden
  }

  private func set(mode: Mode) {
    switch mode {
    case .showingLoading:
      isHidden = false
      showLoadingInterface(true)
      resultStackView.isHidden = true
    case .showingResult:
      isHidden = false
      showLoadingInterface(false)
      resultStackView.isHidden = false
    case .hidden:
      isHidden = true
      showLoadingInterface(false)
      resultStackView.isHidden = true
    }
  }

  private func showLoadingInterface(_ show: Bool) {
    if show {
      loadingStackView.isHidden = false
      loadingIndicator.startAnimating()
    } else {
      loadingStackView.isHidden = true
      loadingIndicator.stopAnimating()
    }
  }

  func showError(
    title: String = "Oops",
    buttonTitle: String? = nil
  )
  {
    set(mode: .showingResult)

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
    set(mode: .showingResult)

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

  func showEmpty(
    title: String = "Empty",
    buttonTitle: String? = nil
  )
  {
    set(mode: .showingResult)

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

  func showLoading(phase: String? = nil) {
    set(mode: .showingLoading)
    loadingLabel.isHidden = true

    if let phase = phase {
      loadingLabel.isHidden = false
      loadingLabel.text = phase
    } else {
      loadingLabel.isHidden = true
    }
  }

  func showProgress(phase: String?, progress: Double) {
    set(mode: .showingLoading)

    loadingLabel.do {
      $0.isHidden = false

      let percentInteger = Int(progress * 100)
      switch (phase, percentInteger) {
      case (nil, 0):
        $0.text = "Loading"
      case let (title?, 0):
        $0.text = title
      case (nil, _):
        let text = String(format: "%d%%", percentInteger)
        $0.text = "Loading \(text)"
      case let (title?, _):
        let text = String(format: "%d%%", percentInteger)
        $0.text = "\(title) \(text)"
      }
    }
  }

  func show<T>(_ state: LoadingState<T>) {
    switch state {
    case let .begin(phase: phase):
      showLoading(phase: phase)
    case let .progress(phase: phase, completed: progress):
      showProgress(phase: phase, progress: progress)
    case .error:
      showError()
    case let .value(value):
      if let value = value as? Emptiable, value.isEmpty {
        showEmpty()
      } else {
        isHidden = true
      }
    }
  }
}

extension Reactive where Base: LoadingStateView {

  func showLoadingState<T>() -> Binder<LoadingState<T>> {
    return Binder(base) { view, state in
      view.show(state)
    }
  }

}
