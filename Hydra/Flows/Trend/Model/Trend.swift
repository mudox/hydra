import GitHub

import RxCocoa
import RxDataSources
import RxSwift

struct Trend {

  struct Item {
    let category: Trending.Category
    let language: String
    let period: Trending.Period
  }

  let repositories: [Item]
  let deveopers: [Item]

  init(of language: String) {
    repositories = [
      Item(category: .repository, language: language, period: .today),
      Item(category: .repository, language: language, period: .thisWeek),
      Item(category: .repository, language: language, period: .thisMonth),
    ]

    deveopers = [
      Item(category: .developer, language: language, period: .today),
      Item(category: .developer, language: language, period: .thisWeek),
      Item(category: .developer, language: language, period: .thisMonth),
    ]
  }

  var sectionModels: [SectionModel<String, Item>] {
    return [
      SectionModel(model: "Repositories", items: repositories),
      SectionModel(model: "Developers", items: deveopers),
    ]
  }

}
