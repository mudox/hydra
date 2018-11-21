import PlaygroundSupport
import UIKit

import Then

class TabSwitchButton: UIButton {

  let title: String

  init(title: String) {
    self.title = title

    super.init(frame: .zero)

    layer.cornerRadius = 4
    layer.masksToBounds = true
    layer.borderWidth = 1
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isSelected: Bool {
    didSet {
      if isSelected {
        let attr = NSAttributedString(string: title, attributes: [
          .font: UIFont.systemFont(ofSize: 12),
          .foregroundColor: UIColor.white
        ])
        setAttributedTitle(attr, for: .normal)

        backgroundColor = .darkGray
        layer.borderColor = UIColor.clear.cgColor

      } else {
        let attr = NSAttributedString(string: title, attributes: [
          .font: UIFont.systemFont(ofSize: 12),
          .foregroundColor: UIColor.lightGray
        ])
        setAttributedTitle(attr, for: .normal)

        backgroundColor = .white
        layer.borderColor = UIColor.lightGray.cgColor

      }
    }
  }
}

class TabSwitch: UIView {

  var buttons = [UIButton]()
  let titles: [String]

  var selectedButtonIndex: Int = 0 {
    didSet {
      buttons[oldValue].isSelected = false
      buttons[selectedButtonIndex].isSelected = true
    }
  }

  init(titles: [String]) {
    self.titles = titles
    super.init(frame: .zero)
    backgroundColor = .white

    setupButtons()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init?(coder:) has not been implemented")
  }

  func setupButtons() {

    buttons = titles.map(TabSwitchButton.init)
    buttons.forEach(addSubview)

    selectedButtonIndex = 0
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let gap: CGFloat = 10
    let xw = bounds.width

    let cnt = CGFloat(buttons.count)
    let w = (xw - gap * (cnt - 1)) / cnt

    buttons.enumerated().forEach {
      let (idx, btn) = $0
      let i = CGFloat(idx)

      btn.frame = CGRect(
        x: i * w + i * gap,
        y: 0,
        width: w,
        height: bounds.height
      )
    }
  }

}

let ts = TabSwitch(titles: ["Repositories", "Developers"])
ts.frame = CGRect(x: 0, y: 0, width: 260, height: 30)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ts
