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

  typealias Section = SectionModel<String, Item>

  let repositories: [Item]
  let deveopers: [Item]

  init(of language: String) {
    repositories = [
      Item(category: .repository, language: language, period: .today),
      Item(category: .repository, language: language, period: .weekly),
      Item(category: .repository, language: language, period: .monthly)
    ]

    deveopers = [
      Item(category: .developer, language: language, period: .today),
      Item(category: .developer, language: language, period: .weekly),
      Item(category: .developer, language: language, period: .monthly)
    ]
  }

  var sectionModels: [Section] {
    return [
      Section(model: "Repositories", items: repositories),
      Section(model: "Developers", items: deveopers)
    ]
  }

}
