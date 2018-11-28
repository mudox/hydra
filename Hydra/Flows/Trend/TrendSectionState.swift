import RxCocoa
import RxSwift

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

  // MARK: - Fakes

  static var fakeErrorLoadingDevelopersDriver: Driver<TrendSectionState> {
    let error = Trending.Error.isDissecting
    let state = TrendSectionState.errorLoadingDevelopers(error)
    return .just(state)
  }

  static var fakeErrorLoadingRepositoriesDriver: Driver<TrendSectionState> {
    let error = Trending.Error.isDissecting
    let state = TrendSectionState.errorLoadingRepositories(error)
    return .just(state)
  }

  static var fakeLoadingRepositoriesDriver: Driver<TrendSectionState> {
    return .just(.loadingRepositories)
  }

  static var fakeLoadingDevelopersDriver: Driver<TrendSectionState> {
    return .just(.loadingDevelopers)
  }
}
