import Foundation

import Moya

import RxSwift

import JacKit

extension GitHub {

  struct Service {
    // MARK: - Singleton

    static let shared = Service()
    private init() {}

    // MARK: - MoyaProvider

    private let provider = MoyaProvider<GitHub.MoyaTarget>().rx

    // MARK: - Search

    typealias SearchRepositoryResponse = GitHub.PagedResponse<GitHub.ResponsePayload.Search>

    func searchRepository(_ query: String) -> Single<SearchRepositoryResponse> {
      return provider.request(.searchRepository(query))
        .map(SearchRepositoryResponse.init)
    }

    // MARK: - User

    typealias CurrentUserResponse = GitHub.Response<GitHub.SignedInUser>

    func currentUser() -> Single<CurrentUserResponse> {
      return provider.request(.currentUser)
        .map(CurrentUserResponse.init)
    }

    typealias UserResponse = GitHub.Response<GitHub.User>

    func user(name: String) -> Single<UserResponse> {
      return provider.request(.user(name: name))
        .map(UserResponse.init)
    }

    // MARK: - Misc

    func zen() -> Single<String> {
      return provider.request(.zen).mapString()
    }

    func rateLimit() -> Single<GitHub.ResponsePayload.RateLimit> {
      return provider.request(.rateLimit)
        .map(GitHub.ResponsePayload.RateLimit.self)
    }

    // MARK: - Authorization

    typealias AuthorizeResponse = GitHub.Response<GitHub.Authorization>

    func authorize() -> Single<AuthorizeResponse> {
      return provider.request(.authorize)
        .map(AuthorizeResponse.init)
    }

    func deauthorize(authorizationID: Int) -> Completable {
      return provider.request(.deauthorize(id: authorizationID))
        .map { response -> Moya.Response in
          if response.statusCode == 204 {
            Jack("GitHub.Service.deauthorize").warn("""
            expect status code 204, got \(response.statusCode)
            \(Jack.dump(of: response))
            """)
          }
          return response
        }
        .asCompletable()
    }

    typealias AuthorizationsResponse = GitHub.PagedResponse<GitHub.Authorization>
    
    func authorizations() -> Single<AuthorizationsResponse> {
      return provider.request(.authorizations)
        .map(AuthorizationsResponse.init)
    }

  } // struct Service
} // extension GitHub
