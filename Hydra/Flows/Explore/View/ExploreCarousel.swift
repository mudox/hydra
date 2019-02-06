import Then
import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import JacKit

import iCarousel
import SnapKit

private let jack = Jack().set(format: .short)

class ExploreCarousel: iCarousel {

  @available(*, unavailable, message: "init(coder:) has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(frame: .zero)
    setupView()
    setupBinding()
  }

  // MARK: - View

  func setupView() {
    type = .linear

    dataSource = self
    delegate = self
  }

  struct Item {
    let logoLocalURL: URL?
    let title: String
    let description: String
  }

  // MARK: - Binding

  let items = BehaviorRelay<[Item]>(value: [])

  private let bag = DisposeBag()

  func setupBinding() {
    reloadDataOnNewItems()
    setupAutoplay()
  }

  func reloadDataOnNewItems() {
    items
      .bind(onNext: { [weak self] _ in
        self?.reloadData()
      })
      .disposed(by: bag)
  }

  func setupAutoplay() {
    Driver<Int>.timer(4, period: 4)
      .drive(onNext: { [weak self] _ in
        self?.scroll(byNumberOfItems: 1, duration: 0.5)
      })
      .disposed(by: bag)
  }

}

// MARK: - iCarouselDataSource

extension ExploreCarousel: iCarouselDataSource {

  func numberOfItems(in carousel: iCarousel) -> Int {
    return items.value.count
  }

  func carousel(
    _ carousel: iCarousel,
    viewForItemAt index: Int,
    reusing view: UIView?
  )
    -> UIView
  {
    let itemView = (view as? ItemView) ?? ItemView()
    let item = items.value[index]
    itemView.show(item: item)
    return itemView
  }

}

// MARK: - iCarouselDelegate

extension ExploreCarousel: iCarouselDelegate {

  func carousel(
    _ carousel: iCarousel,
    valueFor option: iCarouselOption,
    withDefault defaultValue: CGFloat
  )
    -> CGFloat
  {
    switch option {
    case .wrap:
      return 1
    case .spacing:
      return 1 + (10 / 200)
    default:
      return defaultValue
    }
  }

}
