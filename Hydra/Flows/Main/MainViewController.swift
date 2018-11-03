import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import JacKit

private let jack = Jack()

class MainViewController: UIViewController {

  var disposeBag = DisposeBag()

  var model: MainViewModel!

  var flow: MainFlow!

  // MARK: IBOutlets

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

}

private extension MainViewController {

  func setupView() {

  }

  func setupModel() {

  }

}
