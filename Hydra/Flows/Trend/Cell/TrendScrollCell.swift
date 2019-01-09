import UIKit

import RxCocoa
import RxSwift

import SnapKit

import GitHub

class TrendScrollCell: UITableViewCell {

  static let id = "\(type(of: self))"

  var disposeBag = DisposeBag()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    // Size is fixed
    snp.makeConstraints { make in
      make.size.equalTo(TrendScrollCell.height)
    }

    setupLabel()
    setupPageControl()
    setupCollectionView()

    setupBindings()
  }

  @available(*, unavailable, message: "init(coder:) has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View

  let label = UILabel()
  let pageControl = TrendPageControl()
  let collectionView = UICollectionView(frame: .zero)
  
  static let height: CGFloat = 170

  func setupLabel() {
    label.do {
      $0.font = .text
      $0.textColor = .dark
    }

    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().offset(17)
    }
  }

  func setupPageControl() {
    contentView.addSubview(pageControl)
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

    collectionView.do {
      $0.setCollectionViewLayout(layout, animated: false)

      $0.backgroundColor = .clear

      $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
      $0.clipsToBounds = false

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        TrendRepositoryCell.self,
        forCellWithReuseIdentifier: TrendRepositoryCell.id
      )
      $0.register(
        TrendDeveloperCell.self,
        forCellWithReuseIdentifier: TrendDeveloperCell.id
      )
    }

    contentView.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(10)
      make.bottom.equalToSuperview().inset(10)
      make.leading.trailing.equalToSuperview()
    }
  }

  func setupBindings() {
    // Collection view scrolling drives page control
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
  
  // MARK: - Show data

  func show(_ item: Trend.Item) {
    disposeBag = DisposeBag()

    TrendService()
      .repositories(of: item.language, for: item.period)
      .asLoadingStateDriver()
      .map { state -> [LoadingState<Trending.Repository>] in
        switch state {
        case .loading:
          return .init(repeating: .loading, count: 3)
        case let .value(repos):
          return repos.map(LoadingState.value)
        case let .error(error):
          return .init(repeating: .error(error), count: 3)
        }
      }
      .drive(collectionView.rx.items(cellIdentifier: TrendRepositoryCell.id, cellType: TrendRepositoryCell.self)) {
        row, state, cell in
        cell.show(state: state, context: item, at: row)
      }
      .disposed(by: disposeBag)
  }
}
