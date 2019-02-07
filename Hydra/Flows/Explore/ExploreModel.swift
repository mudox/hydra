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

}

protocol ExploreModelOutput {
  var loadingState: BehaviorRelay<ExploreModel.LoadingState> { get }
  var carouselItems: BehaviorRelay<[ExploreModel.Item]> { get }
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

  // MARK: Output

  let loadingState: BehaviorRelay<LoadingState>
  let carouselItems: BehaviorRelay<[ExploreModel.Item]>
  let topicItems: BehaviorRelay<[ExploreModel.Item]>
  let collectionItems: BehaviorRelay<[ExploreModel.Item]>

  // MARK: Binding

  required override init() {
    loadingState = .init(value: .loading)
    carouselItems = .init(value: [])
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
    lists
      .map { lists in
        lists.topics[0 ..< 6].map { topic -> Item in
          Item(
            logoLocalURL: topic.logoLocalURL,
            title: topic.displayName,
            summary: topic.summary
          )
        }
      }
      .bind(to: carouselItems)
      .disposed(by: bag)

    lists
      .map { lists -> [Item] in
        lists.topics.map { topic -> Item in
          Item(
            logoLocalURL: topic.logoLocalURL,
            title: topic.displayName,
            summary: topic.summary
          )
        }
      }
      .bind(to: topicItems)
      .disposed(by: bag)

    lists
      .map { lists -> [Item] in
        lists.collections.map { collection -> Item in
          Item(
            logoLocalURL: collection.logoLocalURL,
            title: collection.displayName,
            summary: collection.description
          )
        }
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
  }

}
