import UIKit

import Then

import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import RxSwiftExt

import SnapKit

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: - Constants

private let cellID = "LanguagesController.Cell.id"
private let headerViewID = "LanguagesController.HeaderView.id"

class LanguagesController: UICollectionViewController {

  init(model: LanguagesModel) {
    self.model = model

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

  let flowLayout: LanguagesFlowLayout

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
  let model: LanguagesModel

  func setupModel() {
    let input = model.input

    disposeBag.insert(
      selectButton.rx.tap.bind(to: input.selectTap),
      searchController.searchBar.rx.text.orEmpty.bind(to: input.searchText)
    )

    let indexPathSelected = collectionView.rx.itemSelected
    let languageSelected = collectionView.rx.modelSelected(String.self)
    Observable.zip(indexPathSelected, languageSelected)
      .map { LanguageSelection(indexPath: $0, language: $1) }
      .bind(to: input.itemTap)
      .disposed(by: disposeBag)

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

    disposeBag.insert(
      pinCommand.bind(to: input.command)
    )

    driveButtons()
    driveCollectionView()
  }

  func driveButtons() {
    let output = model.output

    disposeBag.insert(
      output.selectButtonTitle.asDriver().drive(selectButton.rx.title),
      output.pinButtonEnabled.asDriver().drive(pinButton.rx.isEnabled),
      output.pinButtonTitle.asDriver().drive(pinButton.rx.title)
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
        let cmd = LanguagesModel.Command.movePinnedLanguage(from: srcIndexPath.item, to: destIndexPath.item)
        self?.model.input.command.accept(cmd)
      },
      canMoveItemAtIndexPath: {
        _, indexPath in
        // Can only move items in 'Pinned' section
        indexPath.section == 1
      }
    )
  }()

  func driveCollectionView() {
    let output = model.output

    collectionView.dataSource = nil
    let width = UIScreen.main.bounds.width

    output.collectionViewData.asDriver()
      .do(onNext: { [weak self] sections in
        self?.flowLayout.layout(for: sections, width: width)
      })
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    output.selection.asDriver()
      .drive(onNext: { [weak self] selection in
        self?.collectionView.selectItem(
          at: selection?.indexPath, animated: true, scrollPosition: []
        )
      })
      .disposed(by: disposeBag)
  }

}
