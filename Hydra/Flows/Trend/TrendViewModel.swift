import UIKit

import Action
import RxCocoa
import RxSwift
import RxSwiftExt

import GitHub

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

enum TrendKind {
  case repositories
  case developers
}

struct TrendActionInput {
  let kind: TrendKind
  let language: String
  let period: Trending.Period
}

// MARK: -

enum TrendState {
  case loadingRepository
  case repository(Trending.Repository, rank: Int)
  case errorLoadingRepository(Error)

  case loadingDeveloper
  case developer(Trending.Developer, rank: Int)
  case errorLoadingDeveloper(Error)
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
  var period: BehaviorRelay<Trending.Period> { get }
}

protocol TrendViewModelOutput {
  var dayTrend: Driver<[TrendState]> { get }
  var weekTrend: Driver<[TrendState]> { get }
  var monthTrend: Driver<[TrendState]> { get }
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
  var period = BehaviorRelay<Trending.Period>(value: Trending.Period.today)

  // MARK: - Output

  var dayTrend: Driver<[TrendState]>
  var weekTrend: Driver<[TrendState]>
  var monthTrend: Driver<[TrendState]>

  // MARK: - Private Properties

  typealias TrendAction = Action<TrendActionInput, [TrendState]>

  private let dayAction: TrendAction
  private let weekAction: TrendAction
  private let monthAction: TrendAction

  // MARK: -

  required init(service: TrendServiceType) {

    let input = Observable.combineLatest(
      trendKind, language, period.skip(1),
      resultSelector: TrendActionInput.init
    )

    // Day
    dayAction = trendAction(for: .today, service: service)
    input.filter { $0.period == .today }
      .bind(to: dayAction.inputs)
      .disposed(by: disposeBag)
    dayTrend = dayAction.elements.asDriver { _ in
      jack.function().failure("should not fail")
      return .empty()
    }

    // Week
    weekAction = trendAction(for: .thisWeek, service: service)
    input.filter { $0.period == .thisWeek }
      .bind(to: weekAction.inputs)
      .disposed(by: disposeBag)
    weekTrend = weekAction.elements.asDriver { _ in
      jack.function().failure("should not fail")
      return .empty()
    }

    // Month
    monthAction = trendAction(for: .thisMonth, service: service)
    input.filter { $0.period == .thisMonth }
      .bind(to: monthAction.inputs)
      .disposed(by: disposeBag)
    monthTrend = monthAction.elements.asDriver { _ in
      jack.function().failure("should not fail")
      return .empty()
    }

    // Initial load
    period.accept(.today)
    period.accept(.thisWeek)
    period.accept(.thisMonth)
  }

}

private func trendAction(for period: Trending.Period, service: TrendServiceType) -> TrendViewModel.TrendAction {
  return TrendViewModel.TrendAction { input -> Observable<[TrendState]> in
    switch input.kind {
    case .repositories:
      return service.repositories(of: input.language, for: period)
        .map { $0.enumerated().map { TrendState.repository($1, rank: $0 + 1) } }
        .asObservable()
        .startWith([TrendState](repeating: .loadingRepository, count: 4))
    case .developers:
      return service.developers(of: input.language, for: period)
        .map { $0.enumerated().map { TrendState.developer($1, rank: $0 + 1) } }
        .asObservable()
        .startWith([TrendState](repeating: .loadingDeveloper, count: 4))
    }
  }

}
