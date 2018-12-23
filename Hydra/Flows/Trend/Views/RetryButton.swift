import UIKit

import SnapKit

class RetryButton: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)

    setTitle("Retry", for: .normal)
    setTitleColor(.emptyDark, for: .normal)
    titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .light)

    layer.borderColor = UIColor.emptyDark.cgColor
    layer.borderWidth = 0.5
    layer.cornerRadius = 2

    snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 40, height: 15))
    }
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

}
