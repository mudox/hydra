import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import GitHub
import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol ExploreModelInput {
  var currentCategory: BehaviorRelay<ExploreModel.Category> { get }
}

protocol ExploreModelOutput {
  var loadingState: BehaviorRelay<ExploreModel.LoadingState> { get }

  var featuredItems: BehaviorRelay<[ExploreModel.Item]> { get }

  var topicItems: BehaviorRelay<[ExploreModel.Item]> { get }
  var collectionItems: BehaviorRelay<[ExploreModel.Item]> { get }
}

protocol ExploreModelType: ExploreModelInput, ExploreModelOutput {}

extension ExploreModelType {
  var input: ExploreModelInput { return self }
  var output: ExploreModelOutput { return self }
}

// MARK: - View Model

class ExploreModel: ViewModel, ExploreModelType {

  let service: ExploreServiceType = fx()

  // MARK: Types

  // MARK: Input

  let currentCategory: BehaviorRelay<Category>

  // MARK: Output

  let loadingState: BehaviorRelay<LoadingState>
  let featuredItems: BehaviorRelay<[ExploreModel.Item]>
  let topicItems: BehaviorRelay<[ExploreModel.Item]>
  let collectionItems: BehaviorRelay<[ExploreModel.Item]>

  // MARK: Binding

  required override init() {
    currentCategory = .init(value: .topics)

    loadingState = .init(value: .loading)
    featuredItems = .init(value: [])
    topicItems = .init(value: [])
    collectionItems = .init(value: [])

    super.init()

    service.lists
      .asLoadingStateDriver()
      .drive(loadingState)
      .disposed(by: bag)

    let lists = loadingState
      .filterMap { state -> FilterMap<GitHub.Explore.Lists> in
        if case let LoadingState.value(lists) = state {
          return .map(lists)
        } else {
          return .ignore
        }
      }

    // Fake carousel items
    currentCategory
      .flatMap { [weak self] category -> Single<[Item]> in
        guard let self = self else { return .just([]) }
        switch category {
        case .topics:
          return self.service.featuredTopics
            .map { $0.map(Item.init) }
        case .collections:
          return self.service.featuredCollections
            .map { $0.map(Item.init) }
        }
      }
      .bind(to: featuredItems)
      .disposed(by: bag)

    lists
      .map { lists -> [Item] in
        lists.topics.map(Item.init)
      }
      .bind(to: topicItems)
      .disposed(by: bag)

    lists
      .map { lists -> [Item] in
        lists.collections.map(Item.init)
      }
      .bind(to: collectionItems)
      .disposed(by: bag)
  }

}

// MARK: - Types

extension ExploreModel {

  typealias LoadingState = MudoxKit.LoadingState<GitHub.Explore.Lists>

  struct Item {
    let logoLocalURL: URL?
    let title: String
    let summary: String

    init(from topic: GitHub.CuratedTopic) {
      logoLocalURL = topic.logoLocalURL
      title = topic.displayName
      summary = topic.summary
    }

    init(from collection: GitHub.Collection) {
      logoLocalURL = collection.logoLocalURL
      title = collection.displayName
      summary = collection.description
    }
  }

  enum Category {
    case topics
    case collections
  }
}
