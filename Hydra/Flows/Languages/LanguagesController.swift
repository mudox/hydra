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

  var selectButton: UIBarButtonItem!

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
    selectButton = .init()
    pinButton = .init()

    navigationItem.do {
      $0.title = "Languages"
      $0.leftBarButtonItem = selectButton
      $0.rightBarButtonItem = pinButton
    }

    let normal: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.brand,
      .font: UIFont.text
    ]

    let disabled: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.clear // hide the UIButtonItem
    ]

    selectButton.do {
      $0.title = "Select"
      $0.tintColor = .brand
      $0.setTitleTextAttributes(normal, for: .normal)
      $0.setTitleTextAttributes(normal, for: .highlighted)
    }

    pinButton.do {
      $0.title = "Pin"
      $0.tintColor = .brand
      $0.setTitleTextAttributes(normal, for: .normal)
      $0.setTitleTextAttributes(normal, for: .highlighted)
      $0.setTitleTextAttributes(disabled, for: .disabled)
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
    let input = model.input

    selectButton.rx.tap
      .bind(to: input.selectTap)
      .disposed(by: bag)

    searchController.searchBar.rx.text.orEmpty
      .bind(to: input.searchText)
      .disposed(by: bag)

    PlaceholderView.retry
      .mapTo(LanguagesModel.Command.retry)
      .bind(to: input.command)
      .disposed(by: bag)

    let indexPathSelected = collectionView.rx.itemSelected
    let languageSelected = collectionView.rx.modelSelected(String.self)
    Observable.zip(indexPathSelected, languageSelected)
      .map { LanguagesModel.Selection(indexPath: $0, language: $1) }
      .bind(to: input.itemTap)
      .disposed(by: bag)

    let pinCommand = pinButton.rx.tap
      .withLatestFrom(model.output.selection)
      .flatMap { [weak self] selection -> Observable<LanguagesModel.Command> in
        guard let selected = selection else { return .empty() }
        guard let self = self else { return .empty() }

        let language = selected.language

        let title = self.selectButton.title ?? "<nil>"

        switch self.pinButton.title {
        case "Pin": return .just(.pin(language))
        case "Unpin": return .just(.unpin(language))
        default:
          jack.func().error("Unexpected select button title: \(title)")
          return .empty()
        }
      }

    bag.insert(
      pinCommand.bind(to: input.command)
    )

    driveButtons()
    drivePlaceholderView()
    driveCollectionView()
  }

  func driveButtons() {
    let output = model.output

    bag.insert(
      output.selectButtonTitle.asDriver().drive(selectButton.rx.title),
      output.isPinButtonEnabled.asDriver().drive(pinButton.rx.isEnabled),
      output.pinButtonTitle.asSignal().emit(to: pinButton.rx.title)
    )
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
      moveItem: { [weak self]
        _, srcIndexPath, destIndexPath in
        let cmd = LanguagesModel.Command.movePinned(from: srcIndexPath.item, to: destIndexPath.item)
        self?.model.input.command.accept(cmd)
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

// MARK: - Helpers

private let cellID = "LanguagesController.Cell.id"
private let headerViewID = "LanguagesController.HeaderView.id"
