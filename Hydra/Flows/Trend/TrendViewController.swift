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
  var languageBar: LanguageBar!
  var languageLabel: UILabel!

  var todaySection: TrendSectionView!
  var thisWeekSection: TrendSectionView!
  var thisMonthSection: TrendSectionView!

  func setupView() {
    view.backgroundColor = .bgDark

    // Tab bar
    tabBarItem.image = #imageLiteral(resourceName: "Trend")
    tabBarItem.title = "Trend"
    tabBarController?.tabBar.tintColor = .brand

    setupTabSwitch()
    setupLanguageBar()
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

  func setupLanguageBar() {
    languageBar = LanguageBar()

    view.addSubview(languageBar)
    languageBar.snp.makeConstraints { make in
      make.top.equalTo(tabSwitch.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(10)
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
      make.top.equalTo(languageBar.snp.bottom).offset(10)
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
      .drive(input.kindRelay)
      .disposed(by: disposeBag)

    // Language search bar -> language

    let languages = [
      "All", "C", "JavaScript", "Swift", "Objective-C",
      "Python", "Ruby", "Go", "Rust", "Unknown", "More..."
    ]
    languageBar.languagesRelay.accept(languages)

    languageBar.selectedLanguage
      .drive(input.languageRelay)
      .disposed(by: disposeBag)
  }

  func bindFromModel() {
    let output = model.output

    // Drive collection views

    output.todayTrend
      .map { $0.cellStates }
      .drive(todaySection.collectionView.rx.items)(trendCellConfigurer(period: .today))
      .disposed(by: disposeBag)

    output.thisWeekTrend
      .map { $0.cellStates }
      .drive(thisWeekSection.collectionView.rx.items)(trendCellConfigurer(period: .thisWeek))
      .disposed(by: disposeBag)

    output.thisMonthTrend
      .map { $0.cellStates }
      .drive(thisMonthSection.collectionView.rx.items)(trendCellConfigurer(period: .thisMonth))
      .disposed(by: disposeBag)

    // Fake trending data
//    TrendSectionState.fakeErrorLoadingRepositoriesDriver
//      .map { $0.cellStates }
//      .drive(todaySection.collectionView.rx.items)(trendCellConfigurer(period: .thisWeek))
//      .disposed(by: disposeBag)

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

func trendCellConfigurer(period: Trending.Period)
  -> (UICollectionView, Int, TrendCellState)
  -> UICollectionViewCell
{
  return { view, index, state -> UICollectionViewCell in
    let indexPath = IndexPath(item: index, section: 0)

    switch state {
    case .loadingRepository, .repository, .errorLoadingRepository:
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: TrendRepositoryCell.identifier,
        for: indexPath
      ) as! TrendRepositoryCell // swiftlint:disable:this force_cast
      cell.show(state: state, period: period)
      return cell

    case .loadingDeveloper, .developer, .errorLoadingDeveloper:
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: TrendDeveloperCell.identifier,
        for: indexPath
      ) as! TrendDeveloperCell // swiftlint:disable:this force_cast
      cell.show(state: state, period: period)
      return cell
    }
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
    let width = height / 120 * 190 // Magic number!!!
    return CGSize(width: width, height: height)
  }

}
