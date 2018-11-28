import UIKit

import SnapKit

class ContributorsView: UIView {

  let numberOfAvatars = 5

  let diameter: CGFloat = 12
  var radius: CGFloat { return diameter / 2 }

  var avatarViews: [UIImageView]!

  init() {
    super.init(frame: .zero)

    snp.makeConstraints { make in
      make.width.equalTo(diameter * CGFloat(numberOfAvatars))
      make.height.equalTo(diameter)
    }

    avatarViews = (0 ..< 5).map { _ in makeAvatarView() }

    let stackView = UIStackView(arrangedSubviews: avatarViews).then {
      $0.axis = .horizontal
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = -3
    }

    // Adjust z-order
    avatarViews.reversed().forEach(stackView.bringSubviewToFront)

    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
    }

  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  func makeAvatarView() -> UIImageView {
    return UIImageView().then { iv in
      iv.layer.do {
        $0.cornerRadius = 6
        $0.masksToBounds = true
      }
      iv.backgroundColor = .clear
      iv.snp.makeConstraints { make in
        make.size.equalTo(CGSize(width: diameter, height: diameter))
      }
    }
  }

}
