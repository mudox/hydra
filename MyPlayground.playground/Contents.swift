import SnapKit
import Then
import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

let relay = BehaviorRelay<Int?>(value: nil)

relay.asObservable().pairwise()
  .map { prev, this -> Int? in
    if this != prev {
      return this
    } else {
      return nil
    }
  }
  .debug()
  .subscribe()

relay.accept(1)
relay.accept(1)
relay.accept(nil)
