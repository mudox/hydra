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

protocol TrendModelInput {
  var kindRelay: BehaviorRelay<TrendModel.Kind> { get }
  var languageRelay: BehaviorRelay<String> { get }

  var todayRelay: BehaviorRelay<Void> { get }
  var weekRelay: BehaviorRelay<Void> { get }
  var monthRelay: BehaviorRelay<Void> { get }
}

protocol TrendModelOutput {
  var todayTrend: Driver<TrendState> { get }
  var thisWeekTrend: Driver<TrendState> { get }
  var thisMonthTrend: Driver<TrendState> { get }
}

protocol TrendModelType: TrendModelInput, TrendModelOutput {
  init(service: TrendServiceType)
}

extension TrendModelType {
  var input: TrendModelInput { return self }
  var output: TrendModelOutput { return self }
}

// MARK: - View Model

class TrendModel: TrendModelType {

  // MARK: - Types

  enum Kind: Int {
    case repositories
    case developers
  }

  struct Input {
    let kind: Kind
    let language: String
    let period: Trending.Period
  }

  // MARK: - Input

  var kindRelay = BehaviorRelay<Kind>(value: .repositories)
  var languageRelay = BehaviorRelay<String>(value: "all")

  var todayRelay = BehaviorRelay<Void>(value: ())
  var weekRelay = BehaviorRelay<Void>(value: ())
  var monthRelay = BehaviorRelay<Void>(value: ())

  // MARK: - Output

  var todayTrend: Driver<TrendState>
  var thisWeekTrend: Driver<TrendState>
  var thisMonthTrend: Driver<TrendState>

  // MARK: - Binding

  let disposeBag = DisposeBag()

  required init(service: TrendServiceType) {

    let today = Driver.combineLatest(
      kindRelay.asDriver().distinctUntilChanged(),
      languageRelay.asDriver().skip(1),
      todayRelay.asDriver().mapTo(Trending.Period.today),
      resultSelector: Input.init
    )

    let week = Driver.combineLatest(
      kindRelay.asDriver().distinctUntilChanged(),
      languageRelay.asDriver().skip(1),
      weekRelay.asDriver().mapTo(Trending.Period.thisWeek),
      resultSelector: Input.init
    )

    let month = Driver.combineLatest(
      kindRelay.asDriver().distinctUntilChanged(),
      languageRelay.asDriver().skip(1),
      monthRelay.asDriver().mapTo(Trending.Period.thisMonth),
      resultSelector: Input.init
    )

    todayTrend = trend(triggeredBy: today, service: service)
    thisWeekTrend = trend(triggeredBy: week, service: service)
    thisMonthTrend = trend(triggeredBy: month, service: service)

    NotificationCenter.default.rx.notification(TrendItemCell.retryNotification)
      .bind(onNext: { [weak self] notification in
        guard let self = self else { return }

        if let period = notification.userInfo?["period"] as? Trending.Period {
          switch period {
          case .today:
            self.todayRelay.accept(())
          case .thisWeek:
            self.weekRelay.accept(())
          case .thisMonth:
            self.monthRelay.accept(())
          }
        } else {
          jack.func().error(
            "failed to extract period information from `TrendItemCell.retryNotification`"
          )
        }
      })
      .disposed(by: disposeBag)
  }

}

// MARK: - Helpers

private func trend(
  triggeredBy input: Driver<TrendModel.Input>,
  service: TrendServiceType
)
  -> Driver<TrendState>
{
  return input
    .flatMapLatest { input -> Driver<TrendState> in
      let activity: Activity
      switch input.period {
      case .today: activity = .todayTrend
      case .thisWeek: activity = .thisWeekTrend
      case .thisMonth: activity = .thisMonthTrend
      }

      switch input.kind {
      case .repositories:
        return service.repositories(of: input.language, for: input.period)
          .trackActivity(activity)
          .map(TrendState.repositories)
          .asObservable()
          .startWith(TrendState.loadingRepositories)
          .asDriver { error in
            .just(TrendState.errorLoadingRepositories(error))
          }
      case .developers:
        return service.developers(of: input.language, for: input.period)
          .trackActivity(activity)
          .map(TrendState.developers)
          .asObservable()
          .startWith(TrendState.loadingDevelopers)
          .asDriver { error in
            .just(TrendState.errorLoadingDevelopers(error))
          }
      }
    }
}
