import UIKit

class LanguagesHeaderView: UICollectionReusableView {

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  // MARK: - Subviews

  let label = UILabel()

  // MARK: - View

  func setupView() {
    label.do {
      $0.textColor = .light
      $0.font = .text
    }

    addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func show(title: String) {
    label.text = title
  }

}
