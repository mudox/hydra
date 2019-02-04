import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

class SearchController: ViewController {

  // MARK: - Subviews

  // MARK: - View

  override func setupView() {
    view.backgroundColor = .bgDark

    setupNavigationBar()
  }

  func setupNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  // MARK: - Model

  let model: SearchModelType = fx()

  override func setupModel() {

  }

}

// MARK: - Binders

extension Reactive where Base: SearchController {

}
