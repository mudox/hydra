import Foundation
import Moya

import MudoxKit

import RxCocoa
import RxSwift

import Then

extension GitHub {

  struct Authorization: Decodable {

    struct App: Decodable {

      let name: String
      let url: URL
      let clientID: String

      private enum CodingKeys: String, CodingKey {
        case name
        case url
        case clientID = "client_id"
      }

    }

    let id: Int
    let app: App
    let token: String
    let hashedToken: String
    let note: String
    let noteURL: URL?
    let creationDate: Date
    let updateDate: Date
    let scopes: [String]
    let fingerprint: String?

    private enum CodingKeys: String, CodingKey {
      case id
      case app
      case token
      case hashedToken = "hashed_token"
      case note
      case noteURL = "note_url"
      case creationDate = "created_at"
      case updateDate = "updated_at"
      case scopes
      case fingerprint
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      id = try container.decode(Int.self, forKey: .id)
      app = try container.decode(App.self, forKey: .app)
      token = try container.decode(String.self, forKey: .token)
      hashedToken = try container.decode(String.self, forKey: .hashedToken)
      note = try container.decode(String.self, forKey: .note)
      noteURL = try container.decode(URL?.self, forKey: .noteURL)
      scopes = try container.decode([String].self, forKey: .scopes)
      fingerprint = try container.decode(String?.self, forKey: .fingerprint)

      /*
       *
       * Parse date as RFC3339 date string
       *
       */

      let formatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
      }

      let creationDateString = try container.decode(String.self, forKey: .creationDate)
      if let date = formatter.date(from: creationDateString) {
        creationDate = date
      } else {
        throw DecodingError.dataCorruptedError(
          forKey: .creationDate, in: container,
          debugDescription: "parsing creation date as RFC3339 date failed"
        )
      }

      let updateDateString = try container.decode(String.self, forKey: .updateDate)
      if let date = formatter.date(from: updateDateString) {
        updateDate = date
      } else {
        throw DecodingError.dataCorruptedError(
          forKey: .updateDate, in: container,
          debugDescription: "parsing update date as RFC3339 date failed"
        )
      }

    } // init(from:) throws

  } // struct Authoriztion

}
