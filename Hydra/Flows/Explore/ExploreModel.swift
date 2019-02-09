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

    loadingState = .init(value: .begin(phase: nil))
    featuredItems = .init(value: [])
    topicItems = .init(value: [])
    collectionItems = .init(value: [])

    super.init()

    let states = service.loadLists
      .map(LoadingState.init)
      .startWith(.begin(phase: "Load from cache"))
      .asDriver { return .just(.error($0)) }

    states.drive(loadingState).disposed(by: bag)

    let exploreLists = loadingState
      .filterMap { state -> FilterMap<GitHub.Explore.Lists> in
        if case let LoadingState.value(lists) = state {
          return .map(lists)
        } else {
          return .ignore
        }
      }

    let count = 8
    let topics = exploreLists.map { $0.topics.map(Item.init) }
    let collections = exploreLists.map { $0.collections.map(Item.init) }
    let featuredTopics = topics.map { Array($0.shuffled().prefix(count)) }
    let featuredCollections = collections.map { Array($0.shuffled().prefix(count)) }

    currentCategory
      .distinctUntilChanged()
      .flatMap { category -> Observable<[Item]> in
        switch category {
        case .topics:
          return featuredTopics
        case .collections:
          return featuredCollections
        }
      }
      .bind(to: featuredItems)
      .disposed(by: bag)

    topics
      .bind(to: topicItems)
      .disposed(by: bag)

    collections
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

extension LoadingState where Value == GitHub.Explore.Lists {

  init(from state: GitHub.Explore.ListsLoadingState) {
    switch state {
    case let .downloading(progress: progress):
      self = .progress(phase: "Downloading", completed: progress)
    case .unarchiving:
      self = .begin(phase: "Unarchiving")
    case .parsing:
      self = .begin(phase: "Parsing")
    case let .success(lists):
      self = .value(lists)
    }
  }

}
