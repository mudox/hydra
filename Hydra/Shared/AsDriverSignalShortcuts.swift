import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public extension ObservableConvertibleType {

  func asDriverSkipError(
    label: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("\(dump(of: $0))", file: file, function: function, line: line)
      return .empty()
    }
  }

  func asDriver(
    fallbackTo value: E,
    label: String, file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Fallback to: \(value)
      """, file: file, function: function, line: line)
      return .just(value)
    }
  }

  func asDriver(
    switchTo seq: Driver<E>, label: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Switch to: \(seq)
      """, file: file, function: function, line: line)
      return seq
    }
  }
}

public extension ObservableConvertibleType {

  func asSignalSkipError(
    label: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("\(dump(of: $0))", file: file, function: function, line: line)
      return .empty()
    }
  }

  func asSignal(
    fallbackTo value: E, label: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Fallback to: \(value)
      """, file: file, function: function, line: line)
      return .just(value)
    }
  }

  func asSignal(
    switchTo seq: Signal<E>, label: String,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Switch to: \(seq)
      """, file: file, function: function, line: line)
      return seq
    }
  }
}
