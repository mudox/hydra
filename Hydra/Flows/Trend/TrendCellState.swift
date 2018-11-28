import GitHub

enum TrendCellState {

  // Trending repository
  case loadingRepository
  case repository(Trending.Repository, rank: Int)
  case errorLoadingRepository(Error)

  // Trending developer
  case loadingDeveloper
  case developer(Trending.Developer, rank: Int)
  case errorLoadingDeveloper(Error)

  var isLoading: Bool {
    switch self {
    case .loadingRepository, .loadingDeveloper:
      return true
    default:
      return false
    }
  }

  var error: Error? {
    switch self {
    case let .errorLoadingRepository(error):
      return error
    case let .errorLoadingDeveloper(error):
      return error
    default:
      return nil
    }
  }

}

extension Array where Element == TrendCellState {

  static func isLoading(states: [TrendCellState]) -> Bool {
    if let state = states.first {
      return state.isLoading
    } else { // empty
      return false
    }
  }

}
