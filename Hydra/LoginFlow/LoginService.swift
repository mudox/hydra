import Foundation

import RxCocoa
import RxSwift

import GitHub

import JacKit

private let jack = Jack("LoginService")

protocol LoginServiceType {
  // MARK: Validate user intputs

  func validate(username: String) -> Bool
  func validate(password: String) -> Bool

  // MARK: Login

  var isLoggedIn: Bool { get }

  func login(
    username: String,
    password: String,
    scope: GitHub.AuthScope,
    note: String?
  ) -> Driver<GitHub.Service.AuthorizeResponse>
}

struct LoginService: LoginServiceType {

  let githubService: GitHub.Service

  init(githubService: GitHub.Service) {
    self.githubService = githubService
  }

  func validate(username: String) -> Bool {
    return !username.isEmpty
  }

  func validate(password: String) -> Bool {
    return !password.isEmpty
  }

  var isLoggedIn: Bool {
    return githubService.credentials.isAuthorized
  }

  func login(
    username: String,
    password: String,
    scope: GitHub.AuthScope,
    note: String?
  )
    -> Driver<GitHub.Service.AuthorizeResponse>
  {
    githubService.credentials.user = (name: username, password: password)
    return githubService
      .authorize(scope: scope, note: note)
      .asDriver {
        jack.descendant("login").error(dump(of: $0))
        return .empty()
      }
  }

}
