import UIKit

import RxSwift

import JacKit
import MudoxKit
import Then

private let jack = Jack("ApplicationFlow")

/// Abstract base class for any concrete application flow.
class ApplicationFlow: BaseFlow {

  // MARK: - Override BaseFlow

  override var viewController: UIViewController! {
    get { return window.rootViewController }
    set { window.rootViewController = newValue }
  }

  override var parentFlow: BaseFlow? {
    get {
      return nil
    }
    set {
      fatalError("application flow must always be nil")
    }
  }

  // MARK: - ApplicationFlow

  let window: UIWindow

  init(window: UIWindow) {
    self.window = window
  }

  func start() {
    UIApplication.shared.do { app in
      app.mdx.dumpBasicInfo()
      app.mdx.startTrackingStateChanges()
    }
  }

}
