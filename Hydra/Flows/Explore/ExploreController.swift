import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

import iCarousel

private let jack = Jack().set(format: .short)

class ExploreController: ViewController {

  // MARK: - Subviews

  var carousel: ExploreCarousel!

  var tabView: TabView!

  var collectionView: UICollectionView!

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
    setupCarousel()
  }

  func setupNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: false)
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

  }

  func setupCollectionView() {

  }

  // MARK: - Model

  let model: ExploreModelType = fx()

  override func setupModel() {
    let output = model.output

    output.carouselItems
      .asDriver()
      .drive(carousel.items)
      .disposed(by: bag)
  }

}

// MARK: - Binders

extension Reactive where Base: ExploreController {

}
