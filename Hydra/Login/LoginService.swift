import Foundation

import RxSwift
import RxCocoa

import MudoxKit

import JacKit
fileprivate let jack = Jack().set(level: .verbose)

struct LoginService {
  
  func validate(username: String) -> Bool {
    return !username.isEmpty
  }
  
  func validate(password: String) -> Bool {
    return !password.isEmpty
  }
  
}
