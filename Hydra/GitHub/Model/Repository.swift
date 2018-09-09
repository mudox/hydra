import Foundation

extension GitHub {
  // MARK: - GitHub.Repository

  struct Repository: Decodable {
    let id: Int
    let nodeID: String
    let name: String
    let fullName: String
    let owner: Owner
    let purplePrivate: Bool
    let description: String?
    let isFork: Bool

    let creationDate: String
    let updateDate: String
    let pushDate: String

    private let _homepageString: String?
    var homepageURL: URL? {
      return URL(string: _homepageString ?? "")
    }

    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let language: String
    let hasIssues: Bool
    let hasProjects: Bool
    let hasDownloads: Bool
    let hasWiki: Bool
    let hasPages: Bool
    let forksCount: Int
    let archived: Bool
    let openIssuesCount: Int
    let license: License?
    let forks: Int
    let openIssues: Int
    let watcherCount: Int
    let defaultBranch: String
    let permissions: Permissions?
    let score: Double

    enum CodingKeys: String, CodingKey {
      case archived
      case creationDate = "created_at"
      case defaultBranch = "default_branch"
      case description
      case forks
      case forksCount = "forks_count"
      case fullName = "full_name"
      case hasDownloads = "has_downloads"
      case hasIssues = "has_issues"
      case hasPages = "has_pages"
      case hasProjects = "has_projects"
      case hasWiki = "has_wiki"
      case _homepageString = "homepage"
      case id
      case isFork = "fork"
      case language
      case license
      case name
      case nodeID = "node_id"
      case openIssues = "open_issues"
      case openIssuesCount = "open_issues_count"
      case owner
      case permissions
      case purplePrivate = "private"
      case pushDate = "pushed_at"
      case score
      case size
      case stargazersCount = "stargazers_count"
      case updateDate = "updated_at"
      case watcherCount = "watchers"
      case watchersCount = "watchers_count"
    }

    // MARK: - GitHub.Repository.License

    struct License: Decodable {
      let key: String
      let name: String
      let spdxID: String?

      enum CodingKeys: String, CodingKey {
        case key
        case name
        case spdxID = "spdx_id"
      }
    }

    // MARK: - GitHub.Repository.Owner

    struct Owner: Decodable {
      let login: String
      let id: Int
      let avatarURL: URL
      let type: String
      let siteAdmin: Bool

      enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case id
        case login
        case siteAdmin = "site_admin"
        case type
      }
    }

    // MARK: - GitHub.Repository.Permission

    struct Permissions: Codable {
      let admin: Bool
      let push: Bool
      let pull: Bool
    }
  }
}

