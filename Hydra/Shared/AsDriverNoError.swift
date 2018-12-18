import RxCocoa
import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

public extension ObservableConvertibleType {

  func asDriverNoError() -> Driver<E> {
    return asDriver {
      jack.func().failure("Unexpected error: \($0)")
      return .empty()
    }
  }

}
