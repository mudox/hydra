import UIKit

import RxCocoa
import RxDataSources
import RxSwift

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class TrendController: ViewController {

  init(model: TrendModelType) {
    self.model = model
    super.init()
  }

  // MARK: - View

  let languageBar = LanguageBar()
  let tableView = UITableView()

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
    setupTableView()
    setupTabBar()
  }

  func setupTabBar() {
    navigationController?.tabBarItem.do {
      $0.image = #imageLiteral(resourceName: "Trend")
      $0.selectedImage = #imageLiteral(resourceName: "Trend Selected.pdf")
      $0.title = "Trend"
    }
  }

  func setupNavigationBar() {
    navigationItem.titleView = languageBar
    languageBar.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }
  }

  func setupTableView() {
    tableView.do {
      $0.allowsSelection = false
      $0.tableFooterView = UIView()
      $0.register(TrendScrollCell.self, forCellReuseIdentifier: TrendScrollCell.id)
    }

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  // MARK: - Model

  let model: TrendModelType

  override func setupModel() {
    viewDrivesModel()
    modelDrivesView()
  }

  func viewDrivesModel() {
    let input = model.input

    languageBar.languages = LanguageService().pinnedLanguages

    languageBar.selectedLanguage
      .drive(input.language)
      .disposed(by: disposeBag)
  }

  func modelDrivesView() {

  }

  lazy var dataSource = RxTableViewSectionedReloadDataSource<Trend.Section>(
    configureCell: { _, tableView, _, item in
      // swiftlint:disable:next force_cast
      let cell = tableView.dequeueReusableCell(withIdentifier: TrendScrollCell.id) as! TrendScrollCell
      cell.show(item)
      return cell
    }
  )

}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrendController: UICollectionViewDelegateFlowLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  )
    -> CGSize
  {
    let height = collectionView.bounds.height
    let width = height / 120 * 190 // Magic number!!!
    return CGSize(width: width, height: height)
  }

}

// MARK: - UIScrollViewDelegate

// extension TrendController: UIScrollViewDelegate {
//
//  func scrollViewWillEndDragging(
//    _ scrollView: UIScrollView,
//    withVelocity velocity: CGPoint,
//    targetContentOffset: UnsafeMutablePointer<CGPoint>
//  )
//  {
//    let offset = targetContentOffset.pointee.y
//    let step = sectionGap + TrendView.height
//    let boundary = (offset / step).rounded() * step
//    targetContentOffset.pointee.y = boundary
//  }
// }
