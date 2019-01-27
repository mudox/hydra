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
    flowLayout = LanguagesFlowLayout()
    super.init(collectionViewLayout: flowLayout)
  }

  // MARK: - View

  let flowLayout: LanguagesFlowLayout

  var doneButton: UIBarButtonItem!

  var pinButton: UIBarButtonItem!

  var placeholderView: PlaceholderView!

  var searchController: UISearchController!

  override func setupView() {
    view.backgroundColor = .bgLight

    setupNavigationBar()
    setupSearchBar()
    setupPlaceholderView()
    setupCollectionView()
  }

  func setupNavigationBar() {
    doneButton = .init()
    pinButton = .init()

    navigationItem.do {
      $0.title = "Languages"
      $0.leftBarButtonItem = doneButton
      $0.rightBarButtonItem = pinButton
    }

    let attributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.brand,
      .font: UIFont.text,
    ]

    doneButton.do {
      $0.setTitleTextAttributes(attibutes, for: .normal)
      $0.setTitleTextAttributes(attibutes, for: .highlighted)
    }

    pinButton.do {
      $0.setTitleTextAttributes(attibutes, for: .normal)
      $0.setTitleTextAttributes(attibutes, for: .highlighted)
    }

  }

  func setupSearchBar() {
    searchController = .init(searchResultsController: nil)

    searchController.do {
      $0.obscuresBackgroundDuringPresentation = false
      $0.hidesNavigationBarDuringPresentation = false
    }

    searchController.searchBar.do {
      $0.tintColor = .brand
      $0.placeholder = ""

      $0.autocapitalizationType = .none
    }

    navigationItem.searchController = searchController
  }

  func setupPlaceholderView() {
    placeholderView = PlaceholderView()
    placeholderView.isHidden = true

    view.addSubview(placeholderView)
    placeholderView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
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
      doneButton.rx.tap.bind(to: input.doneButtonTap),
      pinButton.rx.tap.bind(to: input.pinButtonTap),
      searchController.searchBar.rx.text.orEmpty.bind(to: input.searchText),
      PlaceholderView.retry.bind(to: input.retryButtonTap)
    )
    
    // Model -> View
   let output = model.output
    
    output.searchState
      .filterMap { state -> FilterMap<SectionModel<String, String>> in
      
    }
    
    bag.insert(
      output.doneButtonTitle.asDriver().drive(rx.doneButtonTitle),
      output.pinButtonState.asDriver().drive(rx.pinButtonState),
      output.searchState.asDriver().drive(rx.searchState)
    )

    drivePlaceholderView()
    driveCollectionView()
  }

  lazy var dataSource = {
    RxCollectionViewSectionedReloadDataSource<LanguagesSectionModel>(
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
        guard destIndexPath.section == 1 else { return }
        assert(srcIndexPath.section == 1)
        self?.model.input.movePinnedItem
          .accept((from: srcIndexPath.item, to: destIndexPath.item))
      },
      canMoveItemAtIndexPath: {
        _, indexPath in
        // Can only move items in 'Pinned' section
        indexPath.section == 1
      }
    )
  }()

  func drivePlaceholderView() {
    let output = model.output
    output.loadingState.asDriver()
      .drive(onNext: { [weak self] state in
        guard let view = self?.placeholderView else { return }
        switch state {
        case .loading:
          view.showLoading()
        case let .error(error):
          jack.func().error("Error loading all languages data: \(error)")
          view.showGeneralError()
        case .value:
          view.isHidden = true
        }
      })
      .disposed(by: bag)
  }

  func driveCollectionView() {
    let output = model.output

    let width = UIScreen.main.bounds.width
    collectionView.dataSource = nil

    output.collectionViewData
      .asSignal()
      .asObservable()
      .map { $0.toSectionModels() }
      .do(onNext: { [weak self] (sections: [LanguagesSectionModel]) in
        self?.flowLayout.layout(sections, width: width)
      })
      .bind(to: collectionView.rx.items(dataSource: dataSource))
      .disposed(by: bag)

    output.selection.asDriver()
      .drive(onNext: { [weak self] selection in
        self?.collectionView.selectItem(
          at: selection?.indexPath, animated: true, scrollPosition: []
        )
      })
      .disposed(by: bag)
  }

}

// MARK: - Binders

extension Reactive where Base: LanguagesController {

  var doneButtonTitle: Binder<String> {
    return Binder(base.doneButton) { button, title in
      button.title = title
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
        vc.placeholderView.do {
          $0.isHidden = false
          $0.showLoading()
        }
        vc.collectionView.isHidden = true
      case .error:
        vc.placeholderView.do {
          $0.isHidden = false
          $0.showGeneralError()
        }
        vc.collectionView.isHidden = true
      case .empty:
        vc.placeholderView.do {
          $0.isHidden = false
          $0.showEmptyData()
        }
        vc.collectionView.isHidden = true
      case .data:
        vc.placeholderView.isHidden = true
        vc.collectionView.isHidden = false
      }
    }
  }

}

// MARK: - Helpers

private let cellID = "LanguagesController.Cell.id"
private let headerViewID = "LanguagesController.HeaderView.id"
