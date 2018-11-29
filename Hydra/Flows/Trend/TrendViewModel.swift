import UIKit

import Action
import RxCocoa
import RxSwift

import RxSwiftExt

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

protocol TrendServiceType {
  func repositories(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]>
  func developers(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]>
}

extension GitHub.Trending: TrendServiceType {}

// MARK: - Interface

protocol TrendViewModelInput {
  var trendKind: BehaviorRelay<TrendViewModel.Kind> { get }
  var language: BehaviorRelay<String> { get }

  var refreshToday: PublishRelay<Void> { get }
  var refreshThisWeek: PublishRelay<Void> { get }
  var refreshThisMonth: PublishRelay<Void> { get }
}

protocol TrendViewModelOutput {
  var todayTrend: Driver<TrendSectionState> { get }
  var thisWeekTrend: Driver<TrendSectionState> { get }
  var thisMonthTrend: Driver<TrendSectionState> { get }
}

protocol TrendViewModelType: TrendViewModelInput, TrendViewModelOutput {
  init(service: TrendServiceType)
}

extension TrendViewModelType {
  var input: TrendViewModelInput { return self }
  var output: TrendViewModelOutput { return self }
}

// MARK: - View Model

class TrendViewModel: TrendViewModelType {

  // MARK: - Types

  enum Kind: Int {
    case repositories
    case developers
  }

  struct Input {
    let kind: Kind
    let language: String
  }

  // MARK: - Input

  var trendKind = BehaviorRelay<Kind>(value: .repositories)
  var language = BehaviorRelay<String>(value: "all")

  var refreshToday = PublishRelay<Void>()
  var refreshThisWeek = PublishRelay<Void>()
  var refreshThisMonth = PublishRelay<Void>()

  // MARK: - Output

  var todayTrend: Driver<TrendSectionState>
  var thisWeekTrend: Driver<TrendSectionState>
  var thisMonthTrend: Driver<TrendSectionState>

  // MARK: - Binding

  let disposeBag = DisposeBag()

  required init(service: TrendServiceType) {
    let userInput = Driver.combineLatest(
      trendKind.asDriver().distinctUntilChanged(), language.asDriver(),
      resultSelector: Input.init
    )

    todayTrend = trend(with: userInput, for: .today, service: service)
    thisWeekTrend = trend(with: userInput, for: .thisWeek, service: service)
    thisMonthTrend = trend(with: userInput, for: .thisMonth, service: service)
  }

}

// MARK: - Helpers

private func trend(
  with input: Driver<TrendViewModel.Input>,
  for period: Trending.Period,
  service: TrendServiceType
)
  -> Driver<TrendSectionState>
{
  let activity: Activity
  switch period {
  case .today: activity = .todayTrend
  case .thisWeek: activity = .thisWeekTrend
  case .thisMonth: activity = .thisMonthTrend
  }

  return input
    .flatMapLatest { input -> Driver<TrendSectionState> in
      switch input.kind {
      case .repositories:
        return service.repositories(of: input.language, for: period)
          .trackActivity(activity)
          .map(TrendSectionState.repositories)
          .asObservable()
          .startWith(TrendSectionState.loadingRepositories)
          .asDriver { error in
            .just(TrendSectionState.errorLoadingRepositories(error))
          }
      case .developers:
        return service.developers(of: input.language, for: period)
          .trackActivity(activity)
          .map(TrendSectionState.developers)
          .asObservable()
          .startWith(TrendSectionState.loadingDevelopers)
          .asDriver { error in
            .just(TrendSectionState.errorLoadingDevelopers(error))
          }
      }
    }

}
