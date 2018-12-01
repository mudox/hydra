import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendPageControl: UIView {

  private let numberOfPages = 25
  private let dotSize = 3
  private let gap = 3

  private var dots: [UIView]!

  // MARK: - Current Index

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
    set(dotAt: index, color: .light, size: dotSize)
  }

  func lowlight(dotAt index: Int) {
    set(dotAt: index, color: .highlight, size: dotSize + 1)
  }

  func highlight(dotAt index: Int) {
    set(dotAt: index, color: .highlight, size: dotSize + 2)
  }

  var currentIndex: Int = 0 {
    didSet {
      currentIndex = max(0, min(24, currentIndex))

      reset(dotAt: oldValue - 1)
      reset(dotAt: oldValue)
      reset(dotAt: oldValue + 1)

      lowlight(dotAt: currentIndex - 1)
      highlight(dotAt: currentIndex)
      lowlight(dotAt: currentIndex + 1)
    }
  }

  // MARK: - Setup

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

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
  }

}
