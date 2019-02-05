import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import Then

class TabView: UIView {

  private let buttonWidth = 140
  private let height = 24
  private let gap = 10

  private var disposeBag = DisposeBag()

  private let titles: [String]
  private var buttons: [UIButton]!
  private var underline: UIView!

  private let selectedButtonIndexRelay = BehaviorRelay(value: 0)

  var selectedIndex: Driver<Int> {
    return selectedButtonIndexRelay.asDriver()
  }

  init(titles: [String]) {
    self.titles = titles
    super.init(frame: .zero)

    setupView()
    setupBinding()
  }

  @available(*, unavailable, message: "has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init?(coder:) has not been implemented")
  }

  func setupView() {
    // Buttons
    buttons = []
    titles.enumerated().forEach { index, _ in
      let button = makeButton(title: titles[index])
      button.isSelected = (index == 0)
      buttons.append(button)
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

  func setupBinding() {
    // Button taps drive selecection relay
    buttons.enumerated().forEach { index, button in
      button.rx.tap
        .map { _ in index }
        .bind(to: selectedButtonIndexRelay)
        .disposed(by: disposeBag)
    }

    // Selection change buttons appearance
    selectedButtonIndexRelay
      .pairwise()
      .bind(onNext: { [weak self] old, new in
        guard let self = self else { return }
        self.buttons[old].isSelected = false
        self.buttons[new].isSelected = true
      })
      .disposed(by: disposeBag)

    // Selection drives underline's move with spring animation
    selectedButtonIndexRelay
      .bind(onNext: { [weak self] newIndex in
        guard let self = self else { return }
        UIView.animate(
          withDuration: 0.25,
          delay: 0,
          usingSpringWithDamping: 0.5,
          initialSpringVelocity: 2,
          options: [],
          animations: { [weak self] in
            guard let self = self else { return }
            self.underline.snp.updateConstraints { make in
              make.centerX.equalTo((self.buttonWidth / 2) + (self.gap + self.buttonWidth) * newIndex)
            }
            self.layoutIfNeeded()
          }
        )
      })
      .disposed(by: disposeBag)
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
