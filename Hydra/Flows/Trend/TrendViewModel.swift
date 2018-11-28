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
}

protocol TrendViewModelOutput {
  var todayTrend: Driver<[TrendCellState]> { get }
  var thisWeekTrend: Driver<[TrendCellState]> { get }
  var thisMonthTrend: Driver<[TrendCellState]> { get }
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

  var todayTrend: Driver<[TrendCellState]>
  var thisWeekTrend: Driver<[TrendCellState]>
  var thisMonthTrend: Driver<[TrendCellState]>

  // MARK: - Binding

  required init(service: TrendServiceType) {
    let userInput = Driver.combineLatest(
      trendKind.asDriver(), language.asDriver(),
      resultSelector: TrendUserInput.init
    )
    .do(onNext: {
      jack.debug("kind: \($0.kind), language: \($0.language)")
    })

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
  -> Driver<[TrendCellState]>
{
  return input
    .flatMapLatest { input -> Driver<[TrendCellState]> in
      switch input.kind {
      case .repositories:
        return service.repositories(of: input.language, for: period)
          .map { $0.enumerated().map { TrendCellState.repository($1, rank: $0 + 1) } }
          .asObservable()
          .startWith([TrendCellState](repeating: .loadingRepository, count: 4))
          .asDriver { error in
            jack.descendant("trend(for:\(period)").failure("error: \(error)")
            return .empty()
          }
      case .developers:
        return service.developers(of: input.language, for: period)
          .do(onSuccess: {
            jack.debug("developers count: \($0.count)")
          })
          .map { $0.enumerated().map { TrendCellState.developer($1, rank: $0 + 1) } }
          .asObservable()
          .startWith([TrendCellState](repeating: .loadingDeveloper, count: 4))
          .asDriver { error in
            jack.descendant("trend(for:\(period)").failure("error: \(error)")
            return .empty()
          }
      }
    }

}
