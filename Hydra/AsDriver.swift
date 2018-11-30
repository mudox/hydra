import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public extension ObservableConvertibleType {

  func asDriver() -> Driver<E> {
    return asDriver {
      jack.function().failure("unexpected error: \($0)")
      return .empty()
    }
  }

}
