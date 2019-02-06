import UIKit

import Then

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import RxSwiftExt

import NVActivityIndicatorView
import SnapKit

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

class LanguagesController: CollectionController {

  init() {
    let layout = LanguagesFlowLayout()
    super.init(collectionViewLayout: layout)
  }

  // MARK: - Subviews

  var flowLayout: LanguagesFlowLayout {
    // swiftlint:disable:next force_cast
    return collectionView.collectionViewLayout as! LanguagesFlowLayout
  }

  var dismissButton: UIBarButtonItem!

  var pinButton: UIBarButtonItem!

  var loadingStateView: LoadingStateView!

  var searchController: UISearchController!

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .bgLight

    setupNavigationBar()
    setupSearchBar()
    setupCollectionView()
    setupPlaceholderView()
  }

  func setupNavigationBar() {
    dismissButton = .init()
    pinButton = .init()

    navigationItem.do {
      $0.title = "Languages"
      $0.leftBarButtonItem = dismissButton
      $0.rightBarButtonItem = pinButton
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.brand
    ]

    dismissButton.do {
      $0.aid = .dismissLanguagesBarButtonItem

      $0.setTitleTextAttributes(attributes, for: .normal)
      $0.setTitleTextAttributes(attributes, for: .highlighted)
    }

    pinButton.do {
      $0.aid = .pinLanguageBarButtonItem

      $0.setTitleTextAttributes(attributes, for: .normal)
      $0.setTitleTextAttributes(attributes, for: .highlighted)
    }

  }

  func setupSearchBar() {
    // Use search controller here only for embeddig search bar into
    // navigation bar.
    searchController = UISearchController(searchResultsController: nil).then {
      $0.obscuresBackgroundDuringPresentation = false
      $0.hidesNavigationBarDuringPresentation = false
    }

    searchController.searchBar.do {
      $0.aid = .languagesSearchBar

      $0.tintColor = .brand
      $0.placeholder = ""

      $0.autocapitalizationType = .none
    }

    navigationItem.searchController = searchController
  }

  func setupPlaceholderView() {
    loadingStateView = LoadingStateView()

    view.addSubview(loadingStateView)
    loadingStateView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  func setupCollectionView() {
    collectionView.do {
      $0.aid = .languagesCollectionView

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

  let model: LanguagesModelType = fx()

  override func setupModel() {

    // View -> Model
    let input = model.input

    let selection = Observable.zip(
      collectionView.rx.itemSelected,
      collectionView.rx.modelSelected(String.self),
      resultSelector: LanguagesModel.Selection.init
    )

    bag.insert(
      selection.bind(to: input.itemTap),
      dismissButton.rx.tap.bind(to: input.dismissButtonTap),
      pinButton.rx.tap.bind(to: input.pinButtonTap),
      searchController.searchBar.rx.text.orEmpty.bind(to: input.searchText),
      LoadingStateView.retry.bind(to: input.retryButtonTap)
    )

    // Model -> View
    let output = model.output

    collectionView.dataSource = nil

    let data = output.searchState
      .asDriver()
      .flatMap { [weak self] state -> Driver<[SectionModel<String, String>]> in
        guard let self = self else { return .empty() }

        if let data = state.sectionModels {
          self.flowLayout.calculateLayouts(data: data)
          return .just(data)
        } else {
          return .empty()
        }
      }

    bag.insert(
      output.dismissButtonTitle.asDriver().drive(rx.dismissButtonTitle),
      output.pinButtonState.asDriver().drive(rx.pinButtonState),
      output.selection.asDriver().drive(rx.selection),
      output.searchState.asDriver().debounce(0.2).drive(rx.searchState),
      data.drive(collectionView.rx.items(dataSource: dataSource))
    )
  }

  lazy var dataSource = {
    RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(
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
        let title = dataSource[indexPath.section].model
        view.show(title: title)
        return view
      },
      moveItem: { [weak self] _, srcIndexPath, destIndexPath in
        guard srcIndexPath.section == 1 && destIndexPath.section == 1 else {
          jack.func().failure("Pinned item can move within pinned section")
          return
        }
        self?.flowLayout.endMovingPinnedItem()
        self?.model.input.movePinnedItem
          .accept((from: srcIndexPath.item, to: destIndexPath.item))
      },
      canMoveItemAtIndexPath: { [weak self] _, indexPath in
        // Can only move items in 'Pinned' section
        if indexPath.section == 1 {
          self?.model.input.clearSelection.accept(())
          self?.flowLayout.startMovingPinnedItem(at: indexPath)
          return true
        } else {
          return false
        }
      }
    )
  }()

}

// MARK: - Binders

extension Reactive where Base: LanguagesController {

  var dismissButtonTitle: Binder<String> {
    return Binder(base.dismissButton) { button, title in
      button.title = title
    }
  }

  var selection: Binder<LanguagesModel.Selection?> {
    return Binder(base.collectionView) { collectionView, selection in
      collectionView.selectItem(at: selection?.indexPath, animated: true, scrollPosition: [])
    }
  }

  var pinButtonState: Binder<LanguagesModel.PinButtonState> {
    return Binder(base) { vc, state in
      switch state {
      case let .show(title):
        vc.navigationItem.setRightBarButton(vc.pinButton, animated: true)
        vc.pinButton.title = title
      case .hide:
        vc.navigationItem.setRightBarButton(nil, animated: true)
      }
    }
  }

  var searchState: Binder<LanguagesModel.SearchState> {
    return Binder(base) { vc, state in
      switch state {
      case .inProgress:
        vc.loadingStateView.do {
          $0.isHidden = false
          $0.showLoading()
        }
        vc.collectionView.isHidden = true
      case .error:
        vc.loadingStateView.do {
          $0.isHidden = false
          $0.showGeneralError()
        }
        vc.collectionView.isHidden = true
      case .empty:
        vc.loadingStateView.do {
          $0.isHidden = false
          $0.showEmptyData()
        }
        vc.collectionView.isHidden = true
      case .data:
        vc.loadingStateView.isHidden = true
        vc.collectionView.isHidden = false
      }
    }
  }

}

// MARK: - Helpers

private let cellID = "LanguagesController.Cell.id"
private let headerViewID = "LanguagesController.HeaderView.id"
