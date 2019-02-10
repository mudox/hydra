import RxCocoa
import RxDataSources
import RxSwift
import UIKit

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class TrendController: ViewController {

  // MARK: Subviews

  var languagesBar: LanguagesBar!

  var tableView: UITableView!

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
    setupTableView()
  }

  func setupNavigationBar() {
    languagesBar = LanguagesBar()
    navigationItem.titleView = languagesBar

    languagesBar.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
    }

    // Hide shadow under bottom border
    navigationController?.navigationBar.shadowImage = UIImage()
  }

  let sectionHeaderHeight: CGFloat = 40

  func setupTableView() {
    tableView = UITableView()
    tableView.aid = .trendTableView

    tableView.do {
      $0.backgroundColor = .clear

      $0.sectionHeaderHeight = sectionHeaderHeight

      $0.allowsSelection = false

      // Hide all decorating lines
      $0.separatorStyle = .none
      $0.tableFooterView = UIView()

      // Hide all scroll indicators
      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(TrendScrollCell.self, forCellReuseIdentifier: TrendScrollCell.id)

      $0.rx.setDelegate(self).disposed(by: bag)
    }

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  // MARK: - Model

  let model: TrendModelType = fx()

  override func setupModel() {
    drivesModel()
    modelDrives()
  }

  func drivesModel() {
    let input = model.input

    languagesBar.selection
      .drive(input.barSelection)
      .disposed(by: bag)

    languagesBar.moreButton.rx.tap
      .flatMapFirst { [weak self] () -> Driver<String?> in
        guard let self = self else { return .empty() }
        let flow = LanguagesFlow(on: self)
        return flow.selectedLanguage.asDriver(
          onErrorFailWithLabel: "LanguagesFlow.selectedLanguage",
          or: .complete
        )
      }
      .bind(to: input.moreLanguage)
      .disposed(by: bag)
  }

  func modelDrives() {
    let output = model.output

    output.languagesBar.asDriver()
      .map { $0.items }
      .drive(languagesBar.items)
      .disposed(by: bag)

    output.languagesBar.asDriver()
      .map { $0.index }
      .drive(languagesBar.index)
      .disposed(by: bag)

    output.tableViewSections.asDriver()
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: bag)
  }

  lazy var dataSource = RxTableViewSectionedReloadDataSource<Trend.Section>(
    configureCell: { _, tableView, _, context in
      // swiftlint:disable:next force_cast
      let cell = tableView.dequeueReusableCell(withIdentifier: TrendScrollCell.id) as! TrendScrollCell
      cell.show(context)
      return cell
    }
  )

}

// MARK: - UITableViewDelegate

extension TrendController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel().then {
      $0.text = (section == 0) ? "TRENDING REPOSITORIES" : "TRENDING DEVELOPERS"
      $0.textAlignment = .center
      $0.font = .systemFont(ofSize: 14, weight: .bold)

      $0.backgroundColor = .clear
    }

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

    blurView.contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    return blurView
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, indexPath.row) {
    case (0, 2):
      return TrendScrollCell.height + 20
    case (1, 2):
      return TrendScrollCell.height + 20
    default:
      return TrendScrollCell.height
    }
  }

}
