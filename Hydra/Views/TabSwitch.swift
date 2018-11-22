import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import Then

class TabSwitchButton: UIButton {

  let title: String

  init(title: String) {
    self.title = title

    super.init(frame: .zero)

    layer.cornerRadius = 4
    layer.masksToBounds = true
    layer.borderWidth = 1

    setBackgroundImage(UIImage.mdx.color(.hydraHighlight), for: .highlighted)
  }

  @available(*, unavailable, message: "has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isSelected: Bool {
    didSet {
      if isSelected {
        let attr = NSAttributedString(string: title, attributes: [
          .font: UIFont.systemFont(ofSize: 15),
          .foregroundColor: UIColor.white
        ])
        setAttributedTitle(attr, for: .normal)

        backgroundColor = .hydraDark
        layer.borderColor = UIColor.clear.cgColor

      } else {
        let attr = NSAttributedString(string: title, attributes: [
          .font: UIFont.systemFont(ofSize: 15),
          .foregroundColor: UIColor.hydraGray
        ])
        setAttributedTitle(attr, for: .normal)

        backgroundColor = .white
        layer.borderColor = UIColor.hydraGray.cgColor

      }
    }
  }
}

class TabSwitch: UIView {

  var disposeBag = DisposeBag()

  private var buttons: [TabSwitchButton] = []
  private let titles: [String]

  private let selectedButtonIndexRelay = BehaviorRelay(value: 0)

  var selectedButtonIndexDriver: Driver<Int> {
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
    titles.enumerated().forEach { index, title in
      let button = TabSwitchButton(title: title)
      button.isSelected = (index == 0)

      buttons.append(button)
    }

    let container = UIStackView(arrangedSubviews: buttons).then {
      $0.axis = .horizontal
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = 10
    }

    addSubview(container)
    container.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.width.equalTo(120 * buttons.count + (buttons.count - 1) * 10)
      make.height.equalTo(26)
    }
  }

  func setupBinding() {
    buttons.enumerated().forEach { index, button in
      button.rx.tap
        .map { _ in index }
        .bind(to: selectedButtonIndexRelay)
        .disposed(by: disposeBag)
    }

    selectedButtonIndexRelay
      .pairwise()
      .bind(onNext: { [weak self] old, new in
        guard let self = self else { return }
        self.buttons[old].isSelected = false
        self.buttons[new].isSelected = true
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
