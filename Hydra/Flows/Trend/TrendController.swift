import UIKit

import RxCocoa
import RxDataSources
import RxSwift

import SnapKit

import JacKit
import MudoxKit

import GitHub

private let jack = Jack().set(format: .short)

class TrendController: ViewController {

  init(model: TrendModelType) {
    self.model = model
    super.init()
  }

  // MARK: - View

  let languageBar = LanguageBar()

  let tableView = UITableView()

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
    setupTableView()
    setupTabBar()
  }

  func setupTabBar() {
    navigationController?.tabBarItem.do {
      $0.image = #imageLiteral(resourceName: "Trend")
      $0.selectedImage = #imageLiteral(resourceName: "Trend Selected.pdf")
      $0.title = "Trend"
    }
  }

  func setupNavigationBar() {
    navigationItem.titleView = languageBar
    languageBar.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }
  }

  let sectionHeaderHeight: CGFloat = 50

  func setupTableView() {
    tableView.do {
      $0.backgroundColor = .clear

      $0.sectionHeaderHeight = sectionHeaderHeight

      $0.allowsSelection = false

      $0.separatorStyle = .none
      $0.tableFooterView = UIView()

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(TrendScrollCell.self, forCellReuseIdentifier: TrendScrollCell.id)

      $0.rx.setDelegate(self).disposed(by: disposeBag)
    }

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  // MARK: - Model

  let model: TrendModelType

  override func setupModel() {
    viewDrivesModel()
    modelDrivesView()
  }

  func viewDrivesModel() {
    let input = model.input

    languageBar.languages = LanguageService().pinnedLanguages

    languageBar.selectedLanguage
      .drive(input.language)
      .disposed(by: disposeBag)
  }

  func modelDrivesView() {
    let output = model.output

    output.trend
      .map { $0.sections }
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
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
    return UILabel().then {
      $0.text = (section == 0) ? "TRENDING REPOSITORIES" : "TRENDING DEVELOPERS"
      $0.textAlignment = .center
      $0.font = .systemFont(ofSize: 14, weight: .bold)

      $0.backgroundColor = .white
    }
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
