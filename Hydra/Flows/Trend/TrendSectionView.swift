import UIKit

import RxCocoa
import RxSwift

import SnapKit

class TrendSectionView: UIView {

  var disposeBag = DisposeBag()

  var label: UILabel!
  var pageControl: TrendPageControl!
  var collectionView: UICollectionView!

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupLabel()
    setupPageControl()
    setupCollectionView()

    collectionView.rx.didScroll
      .bind(onNext: { [unowned self] in
        let pageWidth = self.collectionView.bounds.width
        let totalWidth = self.collectionView.contentSize.width

        let fullDistance = totalWidth - pageWidth
        guard fullDistance > 0 else {
          self.pageControl.currentIndex = 0
          return
        }

        var x = self.collectionView.contentOffset.x
        x = max(0, x)

        var index = Int(x * 25 / (totalWidth - pageWidth))
        index = min(24, index)

        self.pageControl.currentIndex = index
      })
      .disposed(by: disposeBag)
  }

  func setupLabel() {
    label = UILabel().then {
      $0.font = .text
      $0.textColor = .dark
    }

    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().offset(17)
    }
  }

  func setupPageControl() {
    pageControl = TrendPageControl()
    addSubview(pageControl)
    pageControl.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(22)
      make.centerY.equalTo(label)
    }
  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 10
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
      $0.clipsToBounds = false

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        TrendRepositoryCell.self,
        forCellWithReuseIdentifier: TrendRepositoryCell.identifier
      )
      $0.register(
        TrendDeveloperCell.self,
        forCellWithReuseIdentifier: TrendDeveloperCell.identifier
      )
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(10)
      make.bottom.equalToSuperview().inset(10)
      make.leading.trailing.equalToSuperview()
    }
  }

}
