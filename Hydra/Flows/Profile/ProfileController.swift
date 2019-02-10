import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

class ProfileController: ViewController {

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

  let model: ProfileModelType = fx()

  override func setupModel() {

  }

}

// MARK: - Binders

extension Reactive where Base: ProfileController {

}
