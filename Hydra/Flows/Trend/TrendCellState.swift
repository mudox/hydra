import GitHub

enum TrendSectionState {
  case loadingRepositories
  case repositories([Trending.Repository])
  case errorLoadingRepositories(Error)

  case loadingDevelopers
  case developers([Trending.Developer])
  case errorLoadingDevelopers(Error)

  var isLoading: Bool {
    switch self {
    case .loadingRepositories, .loadingDevelopers:
      return true
    default:
      return false
    }
  }

  var cellStates: [TrendCellState] {
    switch self {
    case .loadingRepositories:
      return .init(repeating: .loadingRepository, count: 3)
    case let .repositories(repos):
      return repos.enumerated()
        .map { TrendCellState.repository($1, rank: $0 + 1) }
    case let .errorLoadingRepositories(error):
      return .init(repeating: .errorLoadingRepository(error), count: 3)

    case .loadingDevelopers:
      return .init(repeating: .loadingDeveloper, count: 3)
    case let .developers(developers):
      return developers.enumerated()
        .map { TrendCellState.developer($1, rank: $0 + 1) }
    case let .errorLoadingDevelopers(error):
      return .init(repeating: .errorLoadingDeveloper(error), count: 3)
    }
  }
}

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
