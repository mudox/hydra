import Foundation
import Moya

import MudoxKit

import RxCocoa
import RxSwift

extension GitHub {

  // MARK: - GitHub.Response<Payload>

  class Response<Payload>: MoyaResponseConvertible where Payload: Decodable {

    let moyaReponse: Moya.Response
    let rateLimit: RateLimit
    let payload: Payload

    required init(response: Moya.Response) throws {
      self.moyaReponse = response
      
      guard let urlResponse = response.response else {
        throw GitHub.Error.noHTTPURLResponse
      }

      let headers = try cast(urlResponse.allHeaderFields, to: [String: String].self)

      guard let rateLimit = GitHub.RateLimit(from: headers) else {
        throw GitHub.Error.initRateLimit(headers: headers)
      }

      self.rateLimit = rateLimit
      payload = try JSONDecoder().decode(Payload.self, from: response.data)
    }
    
    var statusCode: Int {
      return moyaReponse.statusCode
    }
    
    var statusDescription: String {
      let code = statusCode
      let description = HTTPURLResponse.localizedString(forStatusCode: code)
      return "\(code) \(description)"
    }

  }

  // MARK: - GitHub.PagedResponse<Payload>

  class PagedResponse<Payload>: Response<Payload> where Payload: Decodable {

    let pagination: Pagination

    required init(response: Moya.Response) throws {
      guard let urlResponse = response.response else {
        throw GitHub.Error.noHTTPURLResponse
      }

      let headers = try cast(urlResponse.allHeaderFields, to: [String: String].self)

      guard let pagination = GitHub.Pagination(from: headers) else {
        throw GitHub.Error.initPagination(headers: headers)
      }

      self.pagination = pagination

      try super.init(response: response)
    }

  }

}
