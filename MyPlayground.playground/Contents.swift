import SnapKit
import Then
import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

class A {
  static func hi() {
    print(self)
  }
  
  class func ho() {
    print(self)
  }
}

class B: A {
  
}

B.hi()
B.ho()
