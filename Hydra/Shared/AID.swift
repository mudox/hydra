func aid(_ id: AID) -> String {
  return id.rawValue
}

enum AID: String {
  case stageView

  case hud

  // LoginFlow
  case dismissLogin

  case username
  case clearUsername

  case password
  case clearPassword

  case loginButton

  // LanguagesFlow

  // TrendFlow

  // ExploreFlow

  // UserFlow

  // RepositoryFlow

  // DeveloperFlow
}
