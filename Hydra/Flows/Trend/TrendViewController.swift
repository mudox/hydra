import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class TrendViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()

    bindToModel()
    bindFromModel()
  }

  // MARK: - View

  var tabSwitch: TabSwitch!
  var searchBar: UISearchBar!
  var languageLabel: UILabel!

  var todaySection: TrendSectionView!
  var thisWeekSection: TrendSectionView!
  var thisMonthSection: TrendSectionView!

  func setupView() {
    view.backgroundColor = .backDark

    // Tab bar
    tabBarItem.image = #imageLiteral(resourceName: "Trend")
    tabBarItem.title = "Trend"
    tabBarController?.tabBar.tintColor = .highlight

    setupTabSwitch()
    setupSearchBar()
    setupSections()
  }

  func setupTabSwitch() {
    tabSwitch = TabSwitch(titles: ["Repositories", "Developers"])

    view.addSubview(tabSwitch)
    tabSwitch.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
    }
  }

  func setupSearchBar() {
    searchBar = UISearchBar(frame: .zero).then {
      $0.placeholder = ""
      $0.searchBarStyle = .minimal
    }

    view.addSubview(searchBar)
    searchBar.snp.makeConstraints { make in
      make.top.equalTo(tabSwitch.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(10)
    }

    languageLabel = UILabel().then {
      $0.text = "All Languages"
      $0.textColor = .dark
      $0.font = .text
      $0.textAlignment = .center
    }

    view.addSubview(languageLabel)
    languageLabel.snp.makeConstraints { make in
      make.center.equalTo(searchBar)
    }

  }

  func setupSections() {
    todaySection = TrendSectionView().then {
      $0.label.text = "Today"
      $0.collectionView.delegate = self
    }

    thisWeekSection = TrendSectionView().then {
      $0.label.text = "This Week"
      $0.collectionView.delegate = self
    }

    thisMonthSection = TrendSectionView().then {
      $0.label.text = "This Month"
      $0.collectionView.delegate = self
    }

    let sectionsStackView = UIStackView(arrangedSubviews: [todaySection, thisWeekSection, thisMonthSection]).then {
      $0.axis = .vertical
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = 10
      $0.backgroundColor = .red
    }

    view.addSubview(sectionsStackView)
    sectionsStackView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
    }

  }

  // MARK: - Model

  var disposeBag = DisposeBag()
  var model: TrendViewModel!

  func bindToModel() {
    let input = model.input

    // Tab switch -> trend kind

    tabSwitch.selectedIndex
      .map { TrendViewModel.Kind(rawValue: $0)! }
      .drive(input.trendKind)
      .disposed(by: disposeBag)

    // Language search bar -> language (fake)

    input.language.accept("all")
  }

  func bindFromModel() {
    let output = model.output

    // Drive collection views

    output.todayTrend
      .map { $0.cellStates }
      .drive(todaySection.collectionView.rx.items)(setupTrendCell)
      .disposed(by: disposeBag)

    output.thisWeekTrend
      .map { $0.cellStates }
      .drive(thisWeekSection.collectionView.rx.items)(setupTrendCell)
      .disposed(by: disposeBag)

    output.thisMonthTrend
      .map { $0.cellStates }
      .drive(thisMonthSection.collectionView.rx.items)(setupTrendCell)
      .disposed(by: disposeBag)

//    TrendSectionState.fakeErrorLoadingRepositoriesDriver
//      .map { $0.cellStates }
//      .drive(thisWeekSection.collectionView.rx.items)(setupTrendCell)
//      .disposed(by: disposeBag)
//
//    TrendSectionState.fakeLoadingDevelopersDriver
//      .map { $0.cellStates }
//      .drive(thisMonthSection.collectionView.rx.items)(setupTrendCell)
//      .disposed(by: disposeBag)

    // Reset scrolling position on reloading

    let reset = { (view: TrendSectionView) -> (TrendSectionState) -> Void in
      { _ in
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        view.collectionView.scrollRectToVisible(rect, animated: false)
      }
    }

    output.todayTrend
      .filter { $0.isLoading }
      .drive(onNext: reset(todaySection))
      .disposed(by: disposeBag)

    output.thisWeekTrend
      .filter { $0.isLoading }
      .drive(onNext: reset(thisWeekSection))
      .disposed(by: disposeBag)

    output.thisMonthTrend
      .filter { $0.isLoading }
      .drive(onNext: reset(thisMonthSection))
      .disposed(by: disposeBag)

  }

}

let setupTrendCell = {
  (view: UICollectionView, index: Int, state: TrendCellState) -> UICollectionViewCell in
  let indexPath = IndexPath(item: index, section: 0)

  switch state {
  case .loadingRepository, .repository, .errorLoadingRepository:
    let cell = view.dequeueReusableCell(
      withReuseIdentifier: TrendRepositoryCell.identifier,
      for: indexPath
    ) as! TrendRepositoryCell // swiftlint:disable:this force_cast
    cell.show(state: state)
    return cell
  case .loadingDeveloper, .developer, .errorLoadingDeveloper:
    let cell = view.dequeueReusableCell(
      withReuseIdentifier: TrendDeveloperCell.identifier,
      for: indexPath
    ) as! TrendDeveloperCell // swiftlint:disable:this force_cast
    cell.show(state: state)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrendViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  )
    -> CGSize
  {
    let height = collectionView.bounds.height
    let width = height / 120 * 190 // !!!: magic number
    return CGSize(width: width, height: height)
  }

}
