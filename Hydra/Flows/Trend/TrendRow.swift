import UIKit

import SnapKit

class TrendRow: UIView {

  let label = UILabel().then {
    $0.font = .systemFont(ofSize: 16)
    $0.textColor = .hydraDark
  }

  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 10
    }

    return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
      $0.clipsToBounds = false

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(TrendRepositoryCell.self, forCellWithReuseIdentifier: "cell")
    }
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().offset(17)
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(10)
      make.bottom.equalToSuperview().inset(10)
      make.leading.trailing.equalToSuperview()
    }
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

}
