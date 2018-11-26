import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

extension String {
  static let trendRepositoryCellID = "trendRepositoryCell"
  static let trendDeveloperCellID = "trendDeveloperCell"
}

class TrendViewController: UIViewController {

  var disposeBag = DisposeBag()
  var model: TrendViewModel!

  // MARK: - Subviews

  var tabSwitch: TabSwitch!

  var searchBar: UISearchBar!
  var languageLabel: UILabel!

  var daySection: Section!
  var weekSection: Section!
  var monthSection: Section!

  // MARK: - View

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
    handleCellDisplayingEvents()
  }

  func setupView() {
    view.backgroundColor = .white

    // Tab bar
    tabBarItem.image = #imageLiteral(resourceName: "Trend")
    tabBarItem.title = "Trend"
    tabBarController?.tabBar.tintColor = .hydraHighlight

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
      $0.textColor = .hydraDark
      $0.font = .systemFont(ofSize: 16)
      $0.textAlignment = .center
    }

    view.addSubview(languageLabel)
    languageLabel.snp.makeConstraints { make in
      make.center.equalTo(searchBar)
    }

  }

  func setupSections() {
    daySection = Section().then {
      $0.label.text = "Today"
      $0.collectionView.delegate = self
    }

    weekSection = Section().then {
      $0.label.text = "This Week"
      $0.collectionView.delegate = self
    }

    monthSection = Section().then {
      $0.label.text = "This Month"
      $0.collectionView.delegate = self
    }

    let sectionsStackView = UIStackView(arrangedSubviews: [daySection, weekSection, monthSection]).then {
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

  // MARK: - View Model

  func setupTrendRepositoryCell(
    view: UICollectionView,
    index: Int,
    state: TrendState
  )
    -> UICollectionViewCell
  {
    let indexPath = IndexPath(item: index, section: 0)

    switch state {
    case .loadingRepository, .repository, .errorLoadingRepository:
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: .trendRepositoryCellID, for: indexPath
        // swiftlint:disable:next force_cast
      ) as! TrendRepositoryCell
      cell.showState(state)
      return cell
    case .loadingDeveloper, .developer, .errorLoadingDeveloper:
      fatalError("Not yet implemented")
    }
  }

  func setupModel() {
    let output = model.output

    output.dayTrend
//      .filter { states in
//        switch states.first! {
//        case .loadingRepository:
//          return true
//        default:
//          return false
//        }
//      }
      .drive(daySection.collectionView.rx.items)(setupTrendRepositoryCell)
      .disposed(by: disposeBag)

    output.weekTrend
      .drive(weekSection.collectionView.rx.items)(setupTrendRepositoryCell)
      .disposed(by: disposeBag)

    output.monthTrend
      .drive(monthSection.collectionView.rx.items)(setupTrendRepositoryCell)
      .disposed(by: disposeBag)
  }

  enum CellDisplayEvent {
    case show(TrendRepositoryCell)
    case hide(TrendRepositoryCell)

    var cell: TrendRepositoryCell {
      switch self {
      case let .show(cell):
        return cell
      case let .hide(cell):
        return cell
      }
    }
  }

  func handleCellDisplayingEvents() {
    let displayEvents = Observable.merge([
      // swiftlint:disable force_cast
      daySection.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      daySection.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) },
      weekSection.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      weekSection.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) },
      monthSection.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      monthSection.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) }
      // swiftlint:enable force_cast
    ])

    displayEvents.scan(into: Set<Int>()) { occupiedIndexes, event in
      switch event {
      case let .show(cell):
        if cell.isLoading {
          cell.imageIndex = nil
        } else {
          var pool = Set(0 ..< 19) // Magic number here!!!
          pool.subtract(occupiedIndexes)

          if let index = pool.randomElement() {
            occupiedIndexes.insert(index)
            cell.imageIndex = index
          } else {
            jack.function().error("pool should not be empty")
            occupiedIndexes.insert(0)
            cell.imageIndex = 0
          }
        }
      case let .hide(cell):
        if let index = cell.imageIndex {
          occupiedIndexes.remove(index)
          cell.imageIndex = nil
        }
      }
    }
    .subscribe()
    .disposed(by: disposeBag)
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
