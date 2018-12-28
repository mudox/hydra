import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public extension ObservableConvertibleType {

  func asDriverSkipError(label: String) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("\(dump(of: $0))")
      return .empty()
    }
  }

  func asDriver(fallbackTo value: E, label: String) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Fallback to: \(value)
      """)
      return .just(value)
    }
  }

  func asDriver(switchTo seq: Driver<E>, label: String) -> Driver<E> {
    return asDriver {
      jack.sub(label).func().failure("""
      Captured error: \(dump(of: $0))
      Switch to: \(seq)
      """)
      return seq
    }
  }
}

public extension ObservableConvertibleType {

  func asSignalSkipError(label: String) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("\(dump(of: $0))")
      return .empty()
    }
  }

  func asSignal(fallbackTo value: E, label: String) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("""
        Captured error: \(dump(of: $0))
        Fallback to: \(value)
        """)
      return .just(value)
    }
  }

  func asSignal(switchTo seq: Signal<E>, label: String) -> Signal<E> {
    return asSignal {
      jack.sub(label).func().failure("""
        Captured error: \(dump(of: $0))
        Switch to: \(seq)
        """)
      return seq
    }
  }
}
