import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt

import SnapKit
import Then

import JacKit

private let cellID = "languageCellID"

private let jack = Jack().set(format: .short)

class LanguagesController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

  // MARK: - UI Constants

  let contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)

  let rowGap: CGFloat = 8
  let itemGap: CGFloat = 8
  let sectionInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)

  // MARK: - View

  var searchBar: UISearchBar!
  var collectionView: UICollectionView!

  func setupView() {
    view.backgroundColor = .bgLight

    setupSearchBar()
    setupCollectionView()
  }

  func setupSearchBar() {
    searchBar = UISearchBar().then {
      $0.placeholder = "Search Languages"
      $0.searchBarStyle = .minimal
    }

    view.addSubview(searchBar)
    searchBar.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(contentInset)
      make.leading.trailing.equalToSuperview().inset(contentInset)
    }
  }

  func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumLineSpacing = itemGap
      $0.minimumInteritemSpacing = rowGap
      $0.sectionInset = sectionInset
      $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
      $0.backgroundColor = .clear
      $0.register(LanguageCell.self, forCellWithReuseIdentifier: cellID)
    }

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom).offset(14)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(contentInset)
      make.leading.trailing.equalToSuperview().inset(contentInset)
    }
  }

  // MARK: - Model

  var disposeBag = DisposeBag()
  var model: LanguagesModel!

  func setupModel() {
    // view -> model
    let input = model.input

    disposeBag.insert(
      searchBar.rx.text.orEmpty.bind(to: input.searchTextRelay)
    )

    // model -> view
    let output = model.output

    let dataSource = RxCollectionViewSectionedReloadDataSource<LanguagesSectionModel>(configureCell: {
      _, collectionView, indexPath, language in
      // swiftlint:disable:next force_cast
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! LanguageCell
      cell.show(language: language)
      return cell
    })

    output.collectionViewModels
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

}
