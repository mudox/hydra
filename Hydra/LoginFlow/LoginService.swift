import Foundation

import RxCocoa
import RxSwift

import JacKit

private let jack = Jack("LoginService")

struct LoginService {

  func validate(username: String) -> Bool {
    return !username.isEmpty
  }

  func validate(password: String) -> Bool {
    return !password.isEmpty
  }

}
