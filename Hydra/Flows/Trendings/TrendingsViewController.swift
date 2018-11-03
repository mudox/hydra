import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import JacKit

private let jack = Jack()

class TrendingsViewController: UIViewController {

  var disposeBag = DisposeBag()

  var model: TrendingsViewModel!

  var flow: TrendingsFlow!

  // MARK: IBOutlets

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()
  }

}

private extension TrendingsViewController {

  func setupView() {

  }

  func setupModel() {

  }

}
