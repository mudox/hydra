import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import JacKit
import MudoxKit

import Then

private let jack = Jack().set(format: .short)

/// Tab strip showing 2 ~ 4 title buttons
///
/// It uses stack view to layout titles equally, hence can not
/// scroll titles.
///
/// ```swift
/// tabView = TabView(titles: ["Topics", "Collections"])
/// view.addSubview(tabView)
/// tabView.snp.makeConstraints { make in
///   make.top.equalTo(carousel.snp.bottom).offset(12)
///   make.centerX.equalToSuperview()
/// }
/// ```
class TabView: View {

  // MARK: Constants

  private let buttonWidth = 140
  private let height = 24
  private let gap = 10

  // MARK: - Subviews

  private let titles: [String]
  private var buttons: [UIButton]!
  private var underline: UIView!

  let selectedIndex = BehaviorRelay(value: 0)

  init(titles: [String]) {
    self.titles = titles
    super.init()
  }

  override func setupView() {
    // Buttons
    buttons = titles.enumerated().map { index, _ in
      let button = makeButton(title: titles[index])
      button.isSelected = (index == 0)
      return button
    }

    // Stack View
    let stackView = UIStackView(arrangedSubviews: buttons).then {
      $0.axis = .horizontal
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = 10
    }

    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.width.equalTo(buttonWidth * buttons.count + (buttons.count - 1) * gap)
      make.height.equalTo(26)
    }

    // Underline View
    underline = UIView().then {
      $0.isUserInteractionEnabled = false
      $0.backgroundColor = .dark
      $0.layer.cornerRadius = 1
    }
    addSubview(underline)
    underline.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 20, height: 2))
      make.top.equalTo(stackView.snp.bottom)
      make.centerX.equalTo(buttonWidth / 2)
    }
  }

  func makeButton(title: String) -> UIButton {
    return UIButton(type: .custom).then {
      // Title
      $0.setTitle(title, for: .normal)
      $0.titleLabel?.font = .text
      $0.setTitleColor(.dark, for: .selected)
      $0.setTitleColor(.brand, for: .highlighted)
      $0.setTitleColor(.light, for: .normal)
    }
  }

  let scrollOffset = BehaviorRelay<CGFloat>(value: 0)

  override func setupBinding() {
    // Button taps drive selecection relay
    buttons.enumerated().forEach { index, button in
      button.rx.tap
        .mapTo(index)
        .bind(to: selectedIndex)
        .disposed(by: bag)
    }

    // Selection change buttons appearance
    selectedIndex
      .pairwise()
      .bind(onNext: { [weak self] old, new in
        guard let self = self else { return }
        self.buttons[old].isSelected = false
        self.buttons[new].isSelected = true
      })
      .disposed(by: bag)

    scrollOffset
      .bind(onNext: { [weak self] offset in
        guard let self = self else { return }
        self.underline.snp.updateConstraints { make in
          let x = CGFloat(self.buttonWidth / 2) + CGFloat(self.buttonWidth + self.gap) * offset
          make.centerX.equalTo(x)
        }
      })
      .disposed(by: bag)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let gap: CGFloat = 10
    let viewWidth = bounds.width

    let count = CGFloat(buttons.count)
    let width = (viewWidth - gap * (count - 1)) / count

    buttons.enumerated().forEach { index, button in
      let idx = CGFloat(index)

      button.frame = CGRect(
        x: idx * width + idx * gap,
        y: 0,
        width: width,
        height: bounds.height
      )
    }
  }

}
