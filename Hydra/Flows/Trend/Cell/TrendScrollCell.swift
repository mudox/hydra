import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import SnapKit

import GitHub
import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

class TrendScrollCell: TableCell {

  static let id = "\(type(of: self))"

  // MARK: - Subviews

  let label = UILabel()

  let pageControl = TrendPageControl()

  var collectionView: UICollectionView!

  // MARK: - Constants

  static let height: CGFloat = 230

  // MARK: - Setup View

  override func setupView() {
    backgroundColor = .clear

    setupLabel()
    setupPageControl()
    setupCollectionView()

    setupBindings()
  }

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

  // MARK: - Binding

  let pageControlBag = DisposeBag()
  var dataSourceBag = DisposeBag()

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
    switch (context.period, context.category) {
    case (.pastDay, .repository):
      collectionView.aid = .todayRepositoryView
    case (.pastWeek, .repository):
      collectionView.aid = .weeklyRepositoryView
    case (.pastMonth, .repository):
      collectionView.aid = .monthlyRepositoryView
    case (.pastDay, .developer):
      collectionView.aid = .todayDeveloperView
    case (.pastWeek, .developer):
      collectionView.aid = .weeklyDeveloperView
    case (.pastMonth, .developer):
      collectionView.aid = .monthlyDeveloperView
    }

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
    return TrendCardCell.reload
      .filter { $0 == context }
      .mapTo(())
      .startWith(())
      .asDriver(onErrorFailWithLabel: "TrendCardCell.reload", or: .complete)
  }

  func driveCollectionView(with context: Trend.Context) {
    dataSourceBag = DisposeBag()

    let driver = refreshDriver(for: context)

    switch context.category {
    case .repository:
      driver.flatMapFirst {
        fx(TrendServiceType.self)
          .repositories(of: context.language, for: context.period)
          .asLoadingStateDriver()
          .flatMap(cellStates)
      }
      .drive(collectionView.rx.items(cellIdentifier: TrendRepositoryCell.id, cellType: TrendRepositoryCell.self)) {
        row, state, cell in
        cell.show(state: state, context: context, at: row)
      }
      .disposed(by: dataSourceBag)
    case .developer:
      driver.flatMapFirst {
        fx(TrendServiceType.self)
          .developers(of: context.language, for: context.period)
          .asLoadingStateDriver()
          .flatMap(cellStates)
      }
      .drive(collectionView.rx.items(cellIdentifier: TrendDeveloperCell.id, cellType: TrendDeveloperCell.self)) {
        row, state, cell in
        cell.show(state: state, context: context, at: row)
      }
      .disposed(by: dataSourceBag)
    }
  }
}

private func cellStates<T>(from state: LoadingState<[T]>) -> Driver<[LoadingState<T>]> {
  switch state {
  case .begin:
    return .just(.init(repeating: .begin(phase: nil), count: 3))
  case .progress:
    jack.failure("Do not expect `.progress` case")
    return .empty()
  case let .value(value):
    return .just(value.map(LoadingState.value))
  case let .error(error):
    return .just(.init(repeating: .error(error), count: 3))
  }
}
