import UIKit

import RxCocoa
import RxSwift

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class TrendViewController: UIViewController {

  var disposeBag = DisposeBag()
  var model: TrendViewModel!

  // MARK: - Subviews

  var tabSwitch: TabSwitch!

  var searchBar: UISearchBar!
  var languageLabel: UILabel!

  var dayRow: TrendRow!
  var weekRow: TrendRow!
  var monthRow: TrendRow!

  // MARK: - View

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
    setupCellDisplayingEvents()
  }

  func setupView() {
    view.backgroundColor = .white

    tabBarItem.image = #imageLiteral(resourceName: "Trend")
    tabBarItem.title = "Trend"
    tabBarController?.tabBar.tintColor = .hydraHighlight

    setupTabSwitch()
    setupSearchBar()
    setupRows()
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

  func setupRows() {
    dayRow = TrendRow().then {
      $0.label.text = "Today"
      $0.collectionView.delegate = self
    }

    weekRow = TrendRow().then {
      $0.label.text = "This Week"
      $0.collectionView.delegate = self
    }

    monthRow = TrendRow().then {
      $0.label.text = "This Month"
      $0.collectionView.delegate = self
    }

    let rowsStackView = UIStackView(arrangedSubviews: [dayRow, weekRow, monthRow]).then {
      $0.axis = .vertical
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = 10
      $0.backgroundColor = .red
    }

    view.addSubview(rowsStackView)
    rowsStackView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
    }

  }

  // MARK: - View Model

  lazy var setupCell = {
    { [weak self]
      (collectionView: UICollectionView, index: Int, repository: Trending.Repository) -> UICollectionViewCell in
      guard let self = self else { return UICollectionViewCell() }

      let indexPath = IndexPath(item: index, section: 0)
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        as? TrendRepositoryCell else { return UICollectionViewCell() }

      cell.show(
        repository: repository,
        rank: index + 1
      )

      return cell
    }
  }()

  func setupModel() {
    let day = model.output.dayTrending
    let week = model.output.weekTrending
    let month = model.output.monthTrending

    // MARK: Day Row

    Observable.merge(
      day.elements.map { _ in false },
      day.errors.map { _ in true },
      day.executing.filter { $0 }
    )
    .bind(to: dayRow.pageControl.rx.isHidden)
    .disposed(by: disposeBag)

    day.elements
      .bind(to: dayRow.collectionView.rx.items)(setupCell)
      .disposed(by: disposeBag)

    // MARK: Week Row

    Observable.merge(
      week.elements.map { _ in false },
      week.errors.map { _ in true },
      week.executing.filter { $0 }
    )
    .bind(to: weekRow.pageControl.rx.isHidden)
    .disposed(by: disposeBag)

    week.elements
      .bind(to: weekRow.collectionView.rx.items)(setupCell)
      .disposed(by: disposeBag)

    // MARK: Month Row

    Observable.merge(
      month.elements.map { _ in false },
      month.errors.map { _ in true },
      month.executing.filter { $0 }
    )
    .bind(to: monthRow.pageControl.rx.isHidden)
    .disposed(by: disposeBag)

    month.elements
      .bind(to: monthRow.collectionView.rx.items)(setupCell)
      .disposed(by: disposeBag)

  }

  enum CellDisplayEvent {
    case show(TrendRepositoryCell)
    case hide(TrendRepositoryCell)
  }

  func setupCellDisplayingEvents() {
    let displayEvents = Observable.merge([
      // swiftlint:disable force_cast
      dayRow.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      dayRow.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) },
      weekRow.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      weekRow.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) },
      monthRow.collectionView.rx.willDisplayCell.map { CellDisplayEvent.show($0.cell as! TrendRepositoryCell) },
      monthRow.collectionView.rx.didEndDisplayingCell.map { CellDisplayEvent.hide($0.cell as! TrendRepositoryCell) }
      // swiftlint:enable force_cast
    ])

    displayEvents.scan(into: Set<Int>()) { occupiedIndexes, event in
      switch event {

      case let .show(cell):
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

      case let .hide(cell):
        occupiedIndexes.remove(cell.imageIndex)
        cell.cleanup()
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
    let height = dayRow.collectionView.bounds.height
    let width = height / 120 * 190 // !!!: magic number
    return CGSize(width: width, height: height)
  }

}
