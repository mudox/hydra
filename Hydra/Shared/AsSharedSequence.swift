import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public enum AsDriverCaptureError<E> {
  case complete
  case replaceWith(E)
  case switchTo(Driver<E>)
}

public enum AsSignalCaptureError<E> {
  case complete
  case replaceWith(E)
  case switchTo(Signal<E>)
}

public extension ObservableConvertibleType {

  func asDriver(
    onErrorFailWithLabel label: String,
    or strategy: AsDriverCaptureError<E>,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure(
        "\(dump(of: $0))",
        file: file, function: function, line: line
      )
      switch strategy {
      case .complete:
        return .empty()
      case let .replaceWith(value):
        return .just(value)
      case let .switchTo(driver):
        return driver
      }
    }
  }

  func asSignal(
    onErrorFailWithLabel label: String,
    or strategy: AsSignalCaptureError<E>,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure(
        "\(dump(of: $0))",
        file: file, function: function, line: line
      )

      switch strategy {
      case .complete:
        return .empty()
      case let .replaceWith(value):
        return .just(value)
      case let .switchTo(signal):
        return signal
      }
    }
  }

}
