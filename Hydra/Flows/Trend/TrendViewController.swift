import UIKit

import RxCocoa
import RxSwift

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

class TrendViewController: UIViewController {

  var disposeBag = DisposeBag()

  var model: TrendViewModel!

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    setupModel()

  }

}

private extension TrendViewController {

  func setupView() {
    view.backgroundColor = .white

    let tabSwitch = TabSwitch(titles: ["Repositories", "Developers"])
    view.addSubview(tabSwitch)

    tabSwitch.do {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addConstraints([
        $0.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        $0.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: 30),
        $0.widthAnchor.constraint(equalToConstant: 210),
        $0.heightAnchor.constraint(equalToConstant: 35)
      ])
    }

    tabSwitch.selectedButtonIndexDriver
      .drive(onNext: { index in
        jack.info("index: \(index)")
      })
      .disposed(by: disposeBag)

  }

  func setupModel() {

  }

}
