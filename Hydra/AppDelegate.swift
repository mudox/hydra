import UIKit

import RxCocoa
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var flow: AppFlow!

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool
  {

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()

    flow = AppFlow(on: .window(window!))
    _ = flow.run.forever()

    return true
  }

}
