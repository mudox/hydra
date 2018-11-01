import MudoxKit

extension Activity {

  static let login = Activity(
    identifier: "login",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnabled: false
  )

}
