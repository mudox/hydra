import GitHub

import RxCocoa
import RxDataSources
import RxSwift

struct Trend {

  struct Context: Equatable {
    let category: Trending.Category
    let language: String
    let period: Trending.Period
  }

  typealias Section = SectionModel<String, Context>

  let repositories: [Context]
  let deveopers: [Context]

  init(of language: String) {
    repositories = [
      Context(category: .repository, language: language, period: .pastDay),
      Context(category: .repository, language: language, period: .pastWeek),
      Context(category: .repository, language: language, period: .pastMonth)
    ]

    deveopers = [
      Context(category: .developer, language: language, period: .pastDay),
      Context(category: .developer, language: language, period: .pastWeek),
      Context(category: .developer, language: language, period: .pastMonth)
    ]
  }

  var sections: [Section] {
    return [
      Section(model: "Repositories", items: repositories),
      Section(model: "Developers", items: deveopers)
    ]
  }

}
