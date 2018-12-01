import MudoxKit

extension Activity {

  static let login = Activity(
    identifier: "login",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnabled: false
  )

  static let todayTrend = Activity(
    identifier: "todayTrend",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnabled: false
  )

  static let thisWeekTrend = Activity(
    identifier: "thisWeekTrend",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnabled: false
  )

  static let thisMonthTrend = Activity(
    identifier: "thisMonthTrend",
    isNetworkActivity: true,
    maxConcurrency: 1,
    isLoggingEnabled: false
  )
}
