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

  func validate(username: String, password: String) -> Bool

  // MARK: Login

  var isLoggedIn: Bool { get }

  func login(username: String, password: String) -> Single<GitHub.Service.AuthorizeResponse>
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

  func validate(username: String, password: String) -> Bool {
    return validate(username: username) && validate(password: password)
  }

  var isLoggedIn: Bool {
    return githubService.credentials.isAuthorized
  }

  func login(username: String, password: String) -> Single<GitHub.Service.AuthorizeResponse> {
    githubService.credentials.user = (name: username, password: password)
    let scope: GitHub.AuthScope = [.user, .repository, .organization, .notification, .gist]
    return githubService.authorize(scope: scope)
  }

}
