import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import Swinject

import SnapKit

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

class TrendScrollCell: UITableViewCell {

  static let id = "\(type(of: self))"

  let pageControlBag = DisposeBag()
  var dataSourceBag = DisposeBag()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    backgroundColor = .clear

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

  var collectionView: UICollectionView!

  static let height: CGFloat = 230

  func setupLabel() {
    label.do {
      $0.text = "Period"
      $0.font = .text
      $0.textColor = .dark
    }

    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
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
      $0.itemSize = TrendCardCell.size
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

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
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(label.snp.bottom).offset(10)
      make.height.equalTo(TrendCardCell.size.height)
    }
  }

  func setupBindings() {
    // Collection view scrolling drives page control
    collectionView.rx.didScroll
      .bind(onNext: { [weak self] in
        guard let self = self else { return }

        let pageWidth = self.collectionView.bounds.width
        let totalWidth = self.collectionView.contentSize.width

        let fullDistance = totalWidth - pageWidth
        guard fullDistance > 0 else {
          self.pageControl.currentIndex = 0
          return
        }

        var x = self.collectionView.contentOffset.x
        x = max(0, x)

        var index = Int(x * 25 / fullDistance)
        index = min(24, index)

        self.pageControl.currentIndex = index
      })
      .disposed(by: pageControlBag)
  }

  // MARK: - Show data

  func show(_ context: Trend.Context) {
    updateLabel(with: context)
    driveCollectionView(with: context)
  }

  func updateLabel(with context: Trend.Context) {
    switch context.period {
    case .pastDay:
      label.text = "Past Day"
    case .pastWeek:
      label.text = "Past Week"
    case .pastMonth:
      label.text = "Past Month"
    }
  }

  func refreshDriver(for context: Trend.Context) -> Driver<Void> {
    return NotificationCenter.default
      .rx.notification(.retryLoadingTrend)
      .filter { notify in
        if let cellContext = notify.userInfo?["context"] as? Trend.Context {
          return cellContext == context
        } else {
          jack.warn("Can not extract context info from `notification.object`, skip this notification")
          return false
        }
      }
      .mapTo(())
      .startWith(())
      .asDriver { error in
        jack.failure("Unexpected error: \(error)")
        return .empty()
      }
  }

  func driveCollectionView(with context: Trend.Context) {
    dataSourceBag = DisposeBag()

    let driver = refreshDriver(for: context)

    switch context.category {
    case .repository:
      driver.flatMapFirst {
        di.resolve(TrendServiceType.self)!
          .repositories(of: context.language, for: context.period)
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
      }
      .drive(collectionView.rx.items(cellIdentifier: TrendRepositoryCell.id, cellType: TrendRepositoryCell.self)) {
        row, state, cell in
        cell.show(state: state, context: context, at: row)
      }
      .disposed(by: dataSourceBag)
    case .developer:
      driver.flatMapFirst {
        di.resolve(TrendServiceType.self)!
          .developers(of: context.language, for: context.period)
          .asLoadingStateDriver()
          .map { state -> [LoadingState<Trending.Developer>] in
            switch state {
            case .loading:
              return .init(repeating: .loading, count: 3)
            case let .value(repos):
              return repos.map(LoadingState.value)
            case let .error(error):
              return .init(repeating: .error(error), count: 3)
            }
          }
      }
      .drive(collectionView.rx.items(cellIdentifier: TrendDeveloperCell.id, cellType: TrendDeveloperCell.self)) {
        row, state, cell in
        cell.show(state: state, context: context, at: row)
      }
      .disposed(by: dataSourceBag)
    }
  }
}
