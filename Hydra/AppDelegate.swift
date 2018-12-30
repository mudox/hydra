import UIKit

import RxCocoa
import RxSwift

import MudoxKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool
  {

    window = UIWindow(frame: UIScreen.main.bounds)
    window!.makeKeyAndVisible()

    HydraFlow(on: .window(window!)).run()

    return true
  }

}
