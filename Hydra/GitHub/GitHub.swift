import Foundation

import Moya

struct GitHub {
  /// Namespace for all data types modeling response payloads
  enum ResponsePayload {}
}

protocol MoyaResponseConvertible {
  init(response: Moya.Response) throws
}
