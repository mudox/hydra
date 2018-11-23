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
  // swiftlint:disable identifier_name
  func repositories(of: String, in: Trending.Period) -> Single<[Trending.Repository]>
  func developers(of: String, in: Trending.Period) -> Single<[Trending.Developer]>
  // swiftlint:enable identifier_name
}

extension GitHub.Trending: TrendServiceType {}

// MARK: Interface

protocol TrendViewModelInput {
  var languageRelay: BehaviorRelay<String> { get }
  var refreshDayTreding: BehaviorRelay<Void> { get }
  var refreshWeekTreding: BehaviorRelay<Void> { get }
  var refreshMonthTreding: BehaviorRelay<Void> { get }
}

protocol TrendViewModelOutput {
  var dayTrending: Action<String, [Trending.Repository]> { get }
  var weekTrending: Action<String, [Trending.Repository]> { get }
  var monthTrending: Action<String, [Trending.Repository]> { get }
}

protocol TrendViewModelType: TrendViewModelInput, TrendViewModelOutput {
  init(service: TrendServiceType)
}

extension TrendViewModelType {
  var input: TrendViewModelInput { return self }
  var output: TrendViewModelOutput { return self }
}

// MARK: - Impelementation

class TrendViewModel: TrendViewModelType {

  let disposeBag = DisposeBag()

  // MARK: - Input

  var languageRelay = BehaviorRelay<String>(value: "all")
  var refreshDayTreding = BehaviorRelay<Void>(value: ())
  var refreshWeekTreding = BehaviorRelay<Void>(value: ())
  var refreshMonthTreding = BehaviorRelay<Void>(value: ())

  // MARK: - Output

  var dayTrending: Action<String, [Trending.Repository]>
  var weekTrending: Action<String, [Trending.Repository]>
  var monthTrending: Action<String, [Trending.Repository]>

  // MARK: - Life cycle

  required init(service: TrendServiceType) {

    dayTrending = Action { language -> Observable<[Trending.Repository]> in
      service.repositories(of: language, in: .pastDay).asObservable()
    }
    refreshDayTreding
      .withLatestFrom(languageRelay)
      .bind(to: dayTrending.inputs)
      .disposed(by: disposeBag)

    weekTrending = Action { language -> Observable<[Trending.Repository]> in
      service.repositories(of: language, in: .pastWeek).asObservable()
    }
    refreshWeekTreding
      .withLatestFrom(languageRelay)
      .bind(to: weekTrending.inputs)
      .disposed(by: disposeBag)

    monthTrending = Action { language -> Observable<[Trending.Repository]> in
      service.repositories(of: language, in: .pastMonth).asObservable()
    }
    refreshMonthTreding
      .withLatestFrom(languageRelay)
      .bind(to: monthTrending.inputs)
      .disposed(by: disposeBag)
  }

}
