import UIKit

import RxCocoa
import RxSwift

import MudoxKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var appFlow: AppFlowType!

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool
  {

    window = UIWindow(frame: UIScreen.main.bounds)
    window!.makeKeyAndVisible()

    appFlow = HydraFlow(on: .window(window!))
    appFlow.run()

    return true
  }

}
