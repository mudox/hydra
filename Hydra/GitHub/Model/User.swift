import Foundation

extension GitHub {
  class User: Decodable {
    // TODO: remove it when Swift 4.2 fixed the `no initializer` issue.
    @available(*, deprecated, message: "Do not use.")
    private init() {
      fatalError("Swift 4.1")
    }

    // MARK: - Basic Info

    let id: Int

    let name: String
    let loginName: String

    let bio: String
    let blog: String?

    let company: String?
    let hireable: Bool

    let email: String?
    let location: String?

    let avatarURL: URL?
    let gravatarID: String?

    let type: String
    let isSiteAdmin: Bool

    let creationDate: String
    let updateDate: String

    // MARK: - Counts

    let publicRepoCount: Int
    let publicGistCount: Int
    let followerCount: Int
    let followingCount: Int

    private enum CodingKeys: String, CodingKey {
      case avatarURL = "avatar_url"
      case bio
      case blog
      case company
      case creationDate = "created_at"
      case email
      case followerCount = "followers"
      case followingCount = "following"
      case gravatarID = "gravatar_id"
      case hireable
      case id
      case isSiteAdmin = "site_admin"
      case location
      case loginName = "login"
      case name
      case publicGistCount = "public_gists"
      case publicRepoCount = "public_repos"
      case type
      case updateDate = "updated_at"
    }
  }

  // MARK: - GitHub.SignedInUser

  class SignedInUser: User {
    let collaboratorCount: Int
    let privateGistCount: Int
    let privateRepoCount: Int
    let ownedPrivateRepoCount: Int

    let diskUsage: Int
    let is2FAEnabled: Bool?

    let plan: Plan

    private enum CodingKeys: String, CodingKey {
      case collaboratorCount = "collaborators"
      case diskUsage = "disk_usage"
      case ownedPrivateRepoCount = "owned_private_repos"
      case plan
      case privateGistCount = "private_gists"
      case privateRepoCount = "total_private_repos"
      case is2FAEnabled = "two_factor_authentication"
    }

    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      collaboratorCount = try container.decode(Int.self, forKey: .collaboratorCount)
      privateGistCount = try container.decode(Int.self, forKey: .privateGistCount)
      privateRepoCount = try container.decode(Int.self, forKey: .privateRepoCount)
      ownedPrivateRepoCount = try container.decode(Int.self, forKey: .ownedPrivateRepoCount)

      diskUsage = try container.decode(Int.self, forKey: .diskUsage)
      is2FAEnabled = try container.decode(Bool.self, forKey: .is2FAEnabled)

      plan = try container.decode(Plan.self, forKey: .plan)

      try super.init(from: decoder)
    }

    struct Plan: Decodable {
      let collaborators: Int
      let name: String
      let privateRepos: Int
      let space: Int

      private enum CodingKeys: String, CodingKey {
        case collaborators
        case name
        case privateRepos = "private_repos"
        case space
      }
    }
  }
}
