import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public extension ObservableConvertibleType {

  func asDriverNoError() -> Driver<E> {
    return asDriver {
      jack.function().failure("unexpected error: \($0)")
      return .empty()
    }
  }

}
