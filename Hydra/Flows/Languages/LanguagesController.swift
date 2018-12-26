import UIKit

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import RxSwiftExt

import SnapKit
import Then

import JacKit

private let jack = Jack().set(format: .short)

// MARK: - Constants

private let cellID = "LanguagesController.Cell.id"
private let headerViewID = "LanguagesController.HeaderView.id"

class LanguagesController: UICollectionViewController {

  let flowLayout: LanguagesFlowLayout

  init() {
    flowLayout = LanguagesFlowLayout()
    super.init(collectionViewLayout: flowLayout)
  }

  @available(*, unavailable, message: "has not been implemented")
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

  // MARK: - View

  let selectButton = UIBarButtonItem()
  let pinButton = UIBarButtonItem()

  let searchController = UISearchController(searchResultsController: nil)

  func setupView() {
    view.backgroundColor = .bgLight

    setupNavigationBar()
    setupSearchBar()
    setupCollectionView()
  }

  func setupNavigationBar() {
    navigationItem.do {
      $0.title = "Languages"
      $0.leftBarButtonItem = selectButton
      $0.rightBarButtonItem = pinButton
    }

    selectButton.do {
      $0.title = "Select"
      $0.tintColor = .brand
    }

    pinButton.do {
      $0.title = "Pin"
      $0.tintColor = .brand
    }

  }

  func setupSearchBar() {
    searchController.do {
      $0.obscuresBackgroundDuringPresentation = false
    }

    searchController.searchBar.do {
      $0.tintColor = .brand
      $0.placeholder = ""

      $0.autocapitalizationType = .none
    }

    navigationItem.searchController = searchController
  }

  func setupCollectionView() {
    collectionView.do {
      $0.backgroundColor = .clear
      $0.register(Cell.self, forCellWithReuseIdentifier: cellID)
      $0.register(
        HeaderView.self,
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: headerViewID
      )
    }
  }

  // MARK: - Model

  var disposeBag = DisposeBag()
  var model: LanguagesModel!

  func setupModel() {
    // view -> model
    let input = model.input

    disposeBag.insert(
      searchController.searchBar.rx.text.orEmpty.bind(to: input.searchText),
      collectionView.rx.itemSelected.bind(to: input.selectedIndexPath)
    )

    // model -> view

    driveButtons()
    driveCollectionView()
  }

  func driveButtons() {
    let output = model.output

    disposeBag.insert(
      output.selectButtonEnabled.drive(selectButton.rx.isEnabled),
      output.pinButtonEnabled.drive(pinButton.rx.isEnabled),
      output.pinButtonTitle.drive(pinButton.rx.title)
    )
  }

  let dataSource = {
    RxCollectionViewSectionedReloadDataSource<LanguagesModel.Section>(
      configureCell: {
        _, collectionView, indexPath, language in
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: cellID,
          for: indexPath
        ) as! Cell // swiftlint:disable:this force_cast
        cell.show(language: language)
        return cell
      },
      configureSupplementaryView: {
        dataSource, collectionView, kind, indexPath in
        assert(kind == UICollectionView.elementKindSectionHeader)
        let view = collectionView.dequeueReusableSupplementaryView(
          ofKind: UICollectionView.elementKindSectionHeader,
          withReuseIdentifier: headerViewID,
          for: indexPath
        ) as! HeaderView // swiftlint:disable:this force_cast
        let title = dataSource[indexPath.section].title
        view.show(title: title)
        return view
      }
    )
  }()

  func driveCollectionView() {
    let output = model.output

    collectionView.dataSource = nil
    let width = UIScreen.main.bounds.width

    output.collectionViewData
      .do(onNext: { [weak self] sections in
        guard let self = self else { return }
        self.flowLayout.layout(for: sections, width: width)
      })
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    output.currentIndexPath
      .drive(onNext: { [weak self] indexPath in
        self?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
      })
      .disposed(by: disposeBag)
  }

}
