import Foundation

extension GitHub {
  enum Error: Swift.Error {
    // Moya.Response.response: HTTPURLResponse? return nil
    case noHTTPURLResponse
    
    // General casting error
    case casting(from: Any?, to: Any.Type)
    
    // Parsing rate limit information from response header failed
    case initRateLimit(headers: [String: String])
    
    // Parsing pagination information from response header failed
    case initPagination(headers: [String: String])
  }
}
