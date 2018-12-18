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
  var kindRelay: BehaviorRelay<TrendViewModel.Kind> { get }
  var languageRelay: BehaviorRelay<String> { get }

  var todayRelay: BehaviorRelay<Void> { get }
  var weekRelay: BehaviorRelay<Void> { get }
  var monthRelay: BehaviorRelay<Void> { get }
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
    let period: Trending.Period
  }

  // MARK: - Input

  var kindRelay = BehaviorRelay<Kind>(value: .repositories)
  var languageRelay = BehaviorRelay<String>(value: "all")

  var todayRelay = BehaviorRelay<Void>(value: ())
  var weekRelay = BehaviorRelay<Void>(value: ())
  var monthRelay = BehaviorRelay<Void>(value: ())

  // MARK: - Output

  var todayTrend: Driver<TrendSectionState>
  var thisWeekTrend: Driver<TrendSectionState>
  var thisMonthTrend: Driver<TrendSectionState>

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

    NotificationCenter.default.rx.notification(TrendBaseCell.retryNotification)
      .debug("refresh", trimOutput: false)
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
            "failed to extract period information from `TrendBaseCell.retryNotification`"
          )
        }
      })
      .disposed(by: disposeBag)
  }

}

// MARK: - Helpers

private func trend(
  triggeredBy input: Driver<TrendViewModel.Input>,
  service: TrendServiceType
)
  -> Driver<TrendSectionState>
{
  return input
    .flatMapLatest { input -> Driver<TrendSectionState> in
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
          .map(TrendSectionState.repositories)
          .asObservable()
          .startWith(TrendSectionState.loadingRepositories)
          .asDriver { error in
            .just(TrendSectionState.errorLoadingRepositories(error))
          }
      case .developers:
        return service.developers(of: input.language, for: input.period)
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
