import UIKit

import RxCocoa
import RxOptional
import RxSwift
import RxSwiftExt

import JacKit
import MudoxKit

import iCarousel

private let jack = Jack().set(format: .short)

private let reuseID = "cell"

class ExploreController: ViewController {

  // MARK: - Subviews

  var loadingStateView: LoadingStateView!

  var carousel: ExploreCarousel!

  var tabView: TabView!

  var scrollView: UIScrollView!
  var topicsView: UICollectionView!
  var collectionsView: UICollectionView!

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
    setupLoadingStateView()
    setupCarousel()
    setupTabView()
    setupScrollView()
  }

  func setupNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  func setupLoadingStateView() {
    loadingStateView = LoadingStateView()
    loadingStateView.isHidden = true

    view.addSubview(loadingStateView)
    loadingStateView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  func setupCarousel() {
    carousel = ExploreCarousel()

    view.addSubview(carousel)
    carousel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(140)
    }
  }

  func setupTabView() {
    tabView = TabView(titles: ["Topics", "Collections"])

    view.addSubview(tabView)
    tabView.snp.makeConstraints { make in
      make.top.equalTo(carousel.snp.bottom).offset(8)
      make.centerX.equalToSuperview()
    }
  }

  func setupScrollView() {
    scrollView = UIScrollView(frame: .zero).then {
      $0.isPagingEnabled = true

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false
    }

    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(tabView.snp.bottom).offset(12)
      make.bottom.equalToSuperview()
    }

    // Collection view
    topicsView = makeCollectionView()
    collectionsView = makeCollectionView()

    let views: [UIView] = [topicsView, collectionsView]
    let stackView = UIStackView(arrangedSubviews: views).then {
      $0.axis = .horizontal
      $0.distribution = .fillEqually
      $0.alignment = .fill
    }

    scrollView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalToSuperview()
      make.width.equalToSuperview().multipliedBy(2)
    }
  }

  func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumLineSpacing = 8

      $0.estimatedItemSize = CGSize(width: 359, height: 140)
    }

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = true

      $0.register(Cell.self, forCellWithReuseIdentifier: reuseID)
    }

    return collectionView
  }

  // MARK: - Model

  let model: ExploreModelType = fx()

  override func setupModel() {
    tabView.selectedIndex
      .map { index -> ExploreModel.Category in
        return index == 0 ? .topics : .collections
      }
      .bind(to: model.input.currentCategory)
      .disposed(by: bag)

    driveLoadingStateView()
    driveCarousel()
    tabViewDrivesScrollView()
    scrollViewDrivesTabView()
    driveCollectionViews()
  }

  func driveLoadingStateView() {
    let output = model.output

    let state = output.loadingState
      .asDriver()

    bag.insert([
      state.drive(loadingStateView.rx.showLoadingState()),
      state.drive(carousel.rx.hideWhenNoData()),
      state.drive(tabView.rx.hideWhenNoData()),
      state.drive(scrollView.rx.hideWhenNoData())
    ])
  }

  func driveCarousel() {
    let output = model.output

    output.featuredItems
      .asDriver()
      .drive(carousel.items)
      .disposed(by: bag)
  }

  func driveCollectionViews() {
    let output = model.output

    output.topicItems
      .asDriver()
      .drive(topicsView.rx.items(cellIdentifier: reuseID, cellType: Cell.self)) {
        _, item, cell in
        cell.show(item)
      }
      .disposed(by: bag)

    output.collectionItems
      .asDriver()
      .drive(collectionsView.rx.items(cellIdentifier: reuseID, cellType: Cell.self)) {
        _, item, cell in
        cell.show(item)
      }
      .disposed(by: bag)
  }

  func tabViewDrivesScrollView() {
    tabView.selectedIndex
      .asDriver()
      .drive(onNext: { [weak self] index in
        assert((0 ..< 2).contains(index))
        let offset = CGPoint(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0)
        self?.scrollView.setContentOffset(offset, animated: true)
      })
      .disposed(by: bag)
  }

  func scrollViewDrivesTabView() {
    scrollView.rx.contentOffset
      .map { offset in
        offset.x / UIScreen.main.bounds.width
      }
      .bind(to: tabView.scrollOffset)
      .disposed(by: bag)

    let endDraggingWithoutDecelerating = scrollView.rx.didEndDragging
      .asDriver()
      .filter { $0 == false }
      .mapTo(())

    let endDecelerating = scrollView.rx.didEndDecelerating.asDriver()

    Driver
      .merge(endDraggingWithoutDecelerating, endDecelerating)
      .flatMap { [weak self] () -> Driver<Int> in
        guard let self = self else { return .empty() }
        let pageIndex = Int(self.scrollView.contentOffset.x / Info.screenWidth)
        return .just(pageIndex)
      }
      .drive(tabView.selectedIndex)
      .disposed(by: bag)
  }
}
