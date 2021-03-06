import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import JacKit
import MudoxKit

import iCarousel

private let jack = Jack().set(format: .short)

class RxiCarouselDelegateProxy: DelegateProxy<iCarousel, iCarouselDelegate>, DelegateProxyType, iCarouselDelegate
{
  weak var carousel: iCarousel?

  init(carousel: iCarousel) {
    self.carousel = carousel
    super.init(
      parentObject: carousel,
      delegateProxy: RxiCarouselDelegateProxy.self
    )
  }

  static func registerKnownImplementations() {
    register { RxiCarouselDelegateProxy(carousel: $0) }
  }

  static func currentDelegate(for object: iCarousel) -> iCarouselDelegate? {
    return object.delegate
  }

  static func setCurrentDelegate(_ delegate: iCarouselDelegate?, to object: iCarousel) {
    object.delegate = delegate
  }

}

extension Reactive where Base: iCarousel {

  var delegate: DelegateProxy<iCarousel, iCarouselDelegate> {
    return RxiCarouselDelegateProxy.proxy(for: base)
  }

  func setDelegate(_ delegate: RxiCarouselDelegateProxy)
    -> Disposable {
    return RxiCarouselDelegateProxy.installForwardDelegate(
      delegate, retainDelegate: false, onProxyForObject: base
    )
  }

  var willBeginScrollAnimation: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselWillBeginScrollingAnimation(_:)))
      .mapTo(())
    return ControlEvent(events: source)
  }

  var didEndScrollAnimation: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselDidEndScrollingAnimation(_:)))
      .mapTo(())
    return ControlEvent(events: source)

  }

  var willBeginDragging: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselWillBeginDragging(_:)))
      .mapTo(())
    return ControlEvent(events: source)
  }

  var didEndDraggingWillDecelerate: ControlEvent<Bool> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselDidEndDragging(_:willDecelerate:)))
      .map { try cast($0[0], to: Bool.self) }
    return ControlEvent(events: source)
  }

  var willBeginDecelerating: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselWillBeginDecelerating(_:)))
      .mapTo(())
    return ControlEvent(events: source)
  }

  var didEndDecelerating: ControlEvent<Void> {
    let source = delegate
      .methodInvoked(#selector(iCarouselDelegate.carouselDidEndDecelerating(_:)))
      .mapTo(())
    return ControlEvent(events: source)
  }

}
