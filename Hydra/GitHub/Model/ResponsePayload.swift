import Foundation

extension GitHub.ResponsePayload {

  // MARK: - GitHub.Responses.Search

  struct Search: Decodable {

    let totalCount: Int
    let isInComplete: Bool
    let items: [GitHub.Repository]

    private enum CodingKeys: String, CodingKey {
      case totalCount = "total_count"
      case isInComplete = "incomplete_results"
      case items
    }

  }

  // MARK: - GitHub.Responses.RateLimit

  struct RateLimit: Decodable {

    struct Limit: Decodable {
      let limit: Int
      let remaining: Int
      let resetDate: Date

      private enum CodingKeys: String, CodingKey {
        case limit
        case remaining
        case resetDate = "reset"
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        limit = try container.decode(Int.self, forKey: .limit)
        remaining = try container.decode(Int.self, forKey: .remaining)

        // Interpret date number as UTC epoch seconds (since 1970)
        let epochSeconds = try container.decode(TimeInterval.self, forKey: .resetDate)
        resetDate = Date(timeIntervalSince1970: epochSeconds)
      }
    }

    struct Resources: Decodable {
      let core: Limit
      let search: Limit
      let graphQL: Limit

      private enum CodingKeys: String, CodingKey {
        case core
        case search
        case graphQL = "graphql"
      }

    }

    let rate: Limit
    let resources: Resources
  }

}
