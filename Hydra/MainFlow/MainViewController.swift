import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import JacKit
private let jack = Jack().set(options: .short)

class MainViewController: UIViewController {

  // MARK: IBOutlets

  // MARK: - View Model

  var disposeBag = DisposeBag()
//  var viewModel: ViewModel!

  // Create & drive view model
  func setupViewModel() {

  }

  // Bind view model back to view controller
  func bindViewModel() {

  }

  // MARK: - Lifecycle

  // - Create subviews.
  // - Create auto layout constraints.
  func setupView() {

  }

  // Resign keyboard at appropriate time.
  func setupKeyboard() {

  }

  // Setup reactive binding between UI components.
  func setupUIBinding() {

  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupUIBinding()
    setupKeyboard()

    setupViewModel()
    bindViewModel()

    let vc = ViewControllers.create(LoginViewController.self, storyboard: "Login")
    present(vc, animated: false, completion: nil)
  }

}
