import Foundation

import RxCocoa
import RxSwift

import GitHub

import JacKit

private let jack = Jack().set(format: .short)

protocol LoginServiceType {

  // MARK: Validate user intputs

  func validate(username: String) -> Bool

  func validate(password: String) -> Bool

  func validate(username: String, password: String) -> Bool

  // MARK: Login

  var isLoggedIn: Bool { get }

  func login(username: String, password: String) -> Single<GitHub.Service.AuthorizeResponse>
}

struct LoginService: LoginServiceType {

  let github: GitHub.Service = fx()

  func validate(username: String) -> Bool {
    return !username.isEmpty
  }

  func validate(password: String) -> Bool {
    return !password.isEmpty
  }

  func validate(username: String, password: String) -> Bool {
    return validate(username: username) && validate(password: password)
  }

  var isLoggedIn: Bool {
    return github.credentials.isAuthorized
  }

  func login(username: String, password: String) -> Single<GitHub.Service.AuthorizeResponse> {
    github.credentials.user = (name: username, password: password)
    let scope: GitHub.AuthScope = [.user, .repository, .organization, .notification, .gist]
    return github.authorize(scope: scope)
  }

}
