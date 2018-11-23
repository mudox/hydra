import UIKit

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendRankBadge: UIView {

  private let diameter: CGFloat = 20
  private var radius: CGFloat { return diameter / 2 }

  var rank: Int = 1 {
    didSet {
      jack.descendant("rank.didSet").assert(rank > 0, "rank should start with 1")

      if rank < 10 {
        isHidden = false
        rankLabel.text = rank.description
      } else {
        isHidden = true
      }
    }
  }

  private var rankLabel: UILabel!

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .hydraHighlight

    // Layer
    layer.do {
      // Shape
      $0.borderColor = UIColor.white.cgColor
      $0.borderWidth = 1
      $0.cornerRadius = radius

      // Drop shadow
      $0.masksToBounds = false
      $0.shouldRasterize = false // rasterization somehow blur all content above

      $0.shadowOffset = UI.shadowOffset
      $0.shadowOpacity = UI.shadowOpacity
      $0.shadowRadius = UI.shadowRadius
      $0.shadowPath = UIBezierPath(ovalIn: CGRect(x: -1, y: -1, width: diameter + 1, height: diameter + 1)).cgPath
    }

    // Fixed size
    snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: diameter, height: diameter))
    }

    // Rank label
    rankLabel = UILabel().then {
      $0.text = "1"
      $0.textColor = .white
      $0.font = UIFont(name: "American Typewriter", size: 14)
      $0.textAlignment = .center
    }

    addSubview(rankLabel)
    rankLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
    }

  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

}
