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

  var loadingView: NVActivityIndicatorView!

  var selectButton: UIBarButtonItem!
  var pinButton: UIBarButtonItem!

  let searchController = UISearchController(searchResultsController: nil)

  override func setupView() {
    view.backgroundColor = .bgLight

    setupNavigationBar()
    setupSearchBar()
    setupLoadingView()
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

  func setupLoadingView() {
    loadingView = NVActivityIndicatorView(
      frame: .zero,
      type: .orbit,
      color: .brand
    )

    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { make in
      make.center.equalTo(view.safeAreaLayoutGuide)
      make.size.equalTo(50)
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

  let model = fx.resolve(LanguagesModelType.self)!

  override func setupModel() {
    let input = model.input

    bag.insert(
      selectButton.rx.tap.bind(to: input.selectTap),
      searchController.searchBar.rx.text.orEmpty.bind(to: input.searchText)
    )

    let indexPathSelected = collectionView.rx.itemSelected
    let languageSelected = collectionView.rx.modelSelected(String.self)
    Observable.zip(indexPathSelected, languageSelected)
      .map { LanguageSelection(indexPath: $0, language: $1) }
      .bind(to: input.itemTap)
      .disposed(by: bag)

    let pinCommand = pinButton.rx.tap
      .withLatestFrom(model.output.selection)
      .flatMap { [weak self] selection -> Observable<LanguagesModel.Command> in
        guard let selected = selection else { return .empty() }
        guard let self = self else { return .empty() }

        let language = selected.1

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
    driveLoading()
    driveCollectionView()
  }

  func driveButtons() {
    let output = model.output

    bag.insert(
      output.selectButtonTitle.asDriver().drive(selectButton.rx.title),
      output.pinButtonEnabled.asDriver().drive(pinButton.rx.isEnabled),
      output.pinButtonTitle.asSignal().emit(to: pinButton.rx.title)
    )
  }

  lazy var dataSource = {
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

  func driveLoading() {
    let output = model.output
    output.state
      .asDriver()
      .map { $0.isLoading }
      .drive(onNext: { [weak self] isLoading in
        if isLoading {
          self?.loadingView.startAnimating()
        } else {
          self?.loadingView.stopAnimating()
        }
      })
      .disposed(by: bag)
  }

  func driveCollectionView() {
    let output = model.output

    let width = UIScreen.main.bounds.width
    collectionView.dataSource = nil

    output.collectionViewData.asDriver()
      .do(onNext: { [weak self] sections in
        self?.flowLayout.layout(for: sections, width: width)
      })
      .drive(collectionView.rx.items(dataSource: dataSource))
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
