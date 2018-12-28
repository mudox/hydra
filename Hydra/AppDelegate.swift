import UIKit

import RxCocoa
import RxSwift

import MudoxKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var flow: AppFlowType!

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool
  {

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()

    flow = HydraFlow(on: .window(window!))
    _ = flow.run.forever()

    return true
  }

}
