import Moya

extension GitHub {

  enum MoyaTarget {

    // MARK: Search

    case searchRepository(String)

    // MARK: User

    case currentUser
    case user(name: String)

    // MARK: Misc

    case zen
    case rateLimit

    // MARK: Authorization

    case authorize
    case deauthorize(id: Int)
    case authorizations
  }
}

extension GitHub.MoyaTarget: Moya.TargetType {
  public var method: Moya.Method {
    switch self {
    // Search
    case .searchRepository:
      return .get

    // User
    case .user, .currentUser:
      return .get

    // Misc
    case .zen, .rateLimit:
      return .get

    // Auhorization
    case .authorizations:
      return .get
    case .authorize:
      return .post
    case .deauthorize:
      return .delete
    }
  }

  public var baseURL: URL {
    return URL(string: "https://api.github.com")!
  }

  public var path: String {
    switch self {
    // Search
    case .searchRepository:
      return "/search/repositories"

    // User
    case .currentUser:
      return "/user"
    case let .user(name):
      return "/users/\(name)"

    // Misc
    case .zen:
      return "/zen"
    case .rateLimit:
      return "/rate_limit"

    // Authoriztion
    case .authorize, .authorizations:
      return "/authorizations"
    case let .deauthorize(id):
      return "/authoriztions/\(id)"
    }
  }

  public var headers: [String: String]? {
    switch self {
    // Search
    case .searchRepository:
      return Dev.defaultTokenHeaders

    // User
    case .user, .currentUser:
      return Dev.defaultTokenHeaders
    
    // Misc
    case .zen, .rateLimit:
      return Dev.defaultTokenHeaders

    // Authorization
    case .authorize, .deauthorize, .authorizations:
      return Dev.defaultMudoxAuthHeaders
    }
  }

  public var task: Task {
    switch self {
      
    // Search
    case let .searchRepository(query):
      let parameters: [String: Any] = [
        "q": query,
        "sort": "stars",
        "order": "desc",
      ]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    
    // User
    case .user, .currentUser:
      return .requestPlain
      
    // Misc
    case .zen, .rateLimit:
      return .requestPlain
    
    // Authorization
    case .authorize:
      let param: [String: Any] = [
        "note": "Test GitHub.Service.authorize",
        "client_id": Dev.clientID,
        "client_secret": Dev.clientSecret,
        "scopes": [
          "user",
          "repo",
          "admin:org",
          "notifications",
        ],
      ]
      return .requestParameters(parameters: param, encoding: JSONEncoding.default)
    case .deauthorize, .authorizations:
      return .requestPlain
    }
    
  }

  public var validationType: ValidationType {
    return .successCodes
  }

  public var sampleData: Data {
    return Data()
  }
}
