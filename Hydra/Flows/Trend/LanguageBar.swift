import UIKit

import RxCocoa
import RxSwift

import SnapKit

class LanguageBar: UIView {

  var disposeBag = DisposeBag()

  var collectionView: UICollectionView!
  var underline: UIView!

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  init() {
    super.init(frame: .zero)

    setupCollectionView()
    setupUnderline()
    setupBindings()

  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 4
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        LanguageBarItemCell.self,
        forCellWithReuseIdentifier: LanguageBarItemCell.identifier
      )
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setupUnderline() {

  }

  func setupBindings() {
    collectionView.rx.didScroll
      .bind(onNext: { [unowned self] in
        let pageWidth = self.collectionView.bounds.width
        let totalWidth = self.collectionView.contentSize.width

        let fullDistance = totalWidth - pageWidth
        guard fullDistance > 0 else {
          return
        }

        var x = self.collectionView.contentOffset.x
        x = max(0, x)

        var index = Int(x * 25 / (totalWidth - pageWidth))
        index = min(24, index)

      })
      .disposed(by: disposeBag)
  }

}

class LanguageBarItemCell: UICollectionViewCell {

  static let identifier = "\(type(of: self))"

  var label: UILabel!

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    label = UILabel().then {
      $0.textColor = .emptyDark
      $0.font = .text
      $0.textAlignment = .center
    }
  }

}
