import UIKit

import RxSwift

import MudoxKit

protocol AppFlowType: FlowType {

  func start()

}

class BaseAppFlow: BaseFlow, AppFlowType {

  /// Start the application main user logic.
  /// Subclasses need to override this method to put application launching
  /// logic into it.
  func start() {
    UIApplication.shared.do { app in
      app.mdx.dumpBasicInfo()
      app.mdx.startTrackingStateChanges()
    }
  }

}
