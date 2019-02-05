import Then
import UIKit

import RxCocoa
import RxSwift

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

public enum ApplicationState {

  case active
  case inactive
  case background
  case terminated

  init(state: UIApplication.State) {
    switch state {
    case .active:
      self = .active
    case .inactive:
      self = .inactive
    case .background:
      self = .background
    }
  }

}

class RxApplicationDelegateProxy
  // swiftlint:disable colon, comma
  : DelegateProxy<UIApplication, UIApplicationDelegate>
  , DelegateProxyType
  , UIApplicationDelegate
  // swiftlint:enable
{
  weak var application: ParentObject?

  init(application: ParentObject) {
    self.application = application
    super.init(
      parentObject: application,
      delegateProxy: RxApplicationDelegateProxy.self
    )
  }

  static func registerKnownImplementations() {
    register { RxApplicationDelegateProxy(application: $0) }
  }

  static func currentDelegate(for application: ParentObject) -> Delegate? {
    return application.delegate
  }

  static func setCurrentDelegate(_ delegate: Delegate?, to application: ParentObject) {
    application.delegate = delegate
  }

}

extension Reactive where Base: UIApplication {

  var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
    return RxApplicationDelegateProxy.proxy(for: base)
  }

  // Active state can only be enterred through inactive state

  var didBecomeActive: Observable<ApplicationState> {
    return delegate
      .methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
      .map { _ in .active }
  }

  /// Application enter inactive from active.
  ///
  /// Inactive state can enterred from 2 directions:
  /// 1. Active -> Inactive (willResignActive)
  /// 1. Inactive <- Background  (WillEnterForeground)
  var willResignActive: Observable<ApplicationState> {
    return delegate
      .methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:)))
      .map { _ in .inactive }
  }

  /// Application enter inactive from background.
  ///
  /// Inactive state can enterred from 2 directions:
  /// 1. Active -> Inactive (willResignActive)
  /// 1. Inactive <- Background  (WillEnterForeground)
  var willEnterForeground: Observable<ApplicationState> {
    return delegate
      .methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:)))
      .map { _ in .inactive }
  }

  /// Application enter background from inactive.
  ///
  /// Background state can only be enterred through inactive state
  var didEnterBackground: Observable<ApplicationState> {
    return delegate
      .methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
      .map { _ in .background }
  }

  /// Application is being terminated.
  var willTerminate: Observable<ApplicationState> {
    return delegate
      .methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:)))
      .map { _ in .terminated }
  }

  /// Application states signal
  var state: Observable<ApplicationState> {
    return Observable
      .merge(
        didBecomeActive,
        willResignActive,
        willEnterForeground,
        didEnterBackground,
        willTerminate
      )
      .startWith(ApplicationState(state: base.applicationState))
  }
}
