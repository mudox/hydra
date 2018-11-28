import UIKit

import Action
import RxCocoa
import RxSwift

import RxSwiftExt

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum TrendKind: Int {
  case repositories
  case developers
}

private struct TrendUserInput {
  let kind: TrendKind
  let language: String
}

protocol TrendServiceType {
  func repositories(of language: String, for period: Trending.Period) -> Single<[Trending.Repository]>
  func developers(of language: String, for period: Trending.Period) -> Single<[Trending.Developer]>
}

extension GitHub.Trending: TrendServiceType {}

// MARK: - Interface

protocol TrendViewModelInput {
  var trendKind: BehaviorRelay<TrendKind> { get }
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

// MARK: -

class TrendViewModel: TrendViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

  var trendKind = BehaviorRelay<TrendKind>(value: .repositories)
  var language = BehaviorRelay<String>(value: "all")

  var refreshToday = PublishRelay<Void>()
  var refreshThisWeek = PublishRelay<Void>()
  var refreshThisMonth = PublishRelay<Void>()

  // MARK: - Output

  var todayTrend: Driver<TrendSectionState>
  var thisWeekTrend: Driver<TrendSectionState>
  var thisMonthTrend: Driver<TrendSectionState>

  // MARK: - Binding

  required init(service: TrendServiceType) {
    let userInput = Driver.combineLatest(
      trendKind.asDriver(), language.asDriver(),
      resultSelector: TrendUserInput.init
    )

    todayTrend = trend(with: userInput, for: .today, service: service)
    thisWeekTrend = trend(with: userInput, for: .thisWeek, service: service)
    thisMonthTrend = trend(with: userInput, for: .thisMonth, service: service)
  }

}

// MARK: - Helpers

private func trend(
  with input: Driver<TrendUserInput>,
  for period: Trending.Period,
  service: TrendServiceType
)
  -> Driver<TrendSectionState>
{
  return input
    .flatMapLatest { input -> Driver<TrendSectionState> in
      switch input.kind {
      case .repositories:
        return service.repositories(of: input.language, for: period)
          .map(TrendSectionState.repositories)
          .asObservable()
          .startWith(TrendSectionState.loadingRepositories)
          .asDriver { error in
            .just(TrendSectionState.errorLoadingRepositories(error))
          }
      case .developers:
        return service.developers(of: input.language, for: period)
          .map(TrendSectionState.developers)
          .asObservable()
          .startWith(TrendSectionState.loadingDevelopers)
          .asDriver { error in
            .just(TrendSectionState.errorLoadingDevelopers(error))
          }
      }
    }

}
