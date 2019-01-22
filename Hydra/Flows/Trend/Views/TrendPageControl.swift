import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendPageControl: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable, message: "init?(coder:) has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init?(coder:) has not been implemented")
  }

  // MARK: - Metrics

  private let numberOfPages = 25
  private let dotSize = 3
  private let gap = 3

  // MARK: - Colors

  var majorColor: UIColor = .brand
  var secondaryColor: UIColor = .brand
  var normalColor: UIColor = .light

  // MARK: - Subviews

  private var dots: [UIView]!

  // MARK: - Setup

  func setupView() {
    clipsToBounds = false

    dots = (0 ..< numberOfPages).map { _ in
      UIView().then {
        $0.backgroundColor = .light
        $0.layer.cornerRadius = CGFloat(dotSize) / 2

        $0.snp.makeConstraints { make in
          make.size.equalTo(dotSize)
        }
      }
    }

    dots.forEach(addSubview)

    let stackView = UIStackView(arrangedSubviews: dots).then {
      $0.axis = .horizontal
      $0.distribution = .equalCentering
      $0.alignment = .center
    }

    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.height.equalTo(10)
      make.width.equalTo(dotSize * numberOfPages + gap * (numberOfPages - 1))
    }

    setupBinding()
  }

  // MARK: - Binding

  private let bag = DisposeBag()

  func setupBinding() {
    TrendModel.color.asDriver()
      .drive(onNext: { [weak self] color in
        guard let self = self else { return }

        self.majorColor = color
        self.secondaryColor = color
        self.show(index: self.currentIndex)
      })
      .disposed(by: bag)
  }

  // MARK: - Show Current Index

  func set(dotAt index: Int, color: UIColor, size: Int) {
    let size = CGFloat(size)

    guard dots.indices.contains(index) else {
      return
    }

    let dot = dots[index]

    dot.layer.cornerRadius = size / 2
    dot.backgroundColor = color
    dot.snp.updateConstraints { make in
      make.size.equalTo(size)
    }
  }

  func reset(dotAt index: Int) {
    set(dotAt: index, color: normalColor, size: dotSize)
  }

  func lowlight(dotAt index: Int) {
    set(dotAt: index, color: secondaryColor, size: dotSize + 1)
  }

  func highlight(dotAt index: Int) {
    set(dotAt: index, color: majorColor, size: dotSize + 2)
  }

  func show(index: Int) {
    (0 ..< numberOfPages).forEach(reset)

    lowlight(dotAt: index - 1)
    highlight(dotAt: index)
    lowlight(dotAt: index + 1)
  }

  var currentIndex: Int = 0 {
    didSet {
      jack.assert(
        (0 ..< numberOfPages).contains(currentIndex),
        "Index (\(currentIndex)) out of range \(0 ..< numberOfPages)"
      )
      currentIndex = max(0, min(numberOfPages - 1, currentIndex))
      show(index: currentIndex)
    }
  }
}
