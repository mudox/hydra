import UIKit

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

    flow = AppFlow(stage: .window(window!))
    flow.start()

    return true
  }

}
