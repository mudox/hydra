import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol ExploreModelInput {

}

protocol ExploreModelOutput {
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

  let carouselItems: BehaviorRelay<[Item]>
  let topicItems: BehaviorRelay<[Item]>
  let collectionItems: BehaviorRelay<[Item]>

  // MARK: Binding

  required override init() {
    carouselItems = .init(value: [])
    topicItems = .init(value: [])
    collectionItems = .init(value: [])

    super.init()

    // Fake
    service.topics
      .map { topics in
        topics[0 ..< 6].map { topic -> Item in
          return .init(
            logoLocalURL: topic.logoLocalURL,
            title: topic.displayName,
            description: topic.summary
          )
        }
      }
      .asObservable()
      .bind(to: carouselItems)
      .disposed(by: bag)

    service.topics
      .asLoadingStateDriver()
      .map { topics -> [Item] in
        topics.map { topic -> Item in
          Item(
            logoLocalURL: topic.logoLocalURL,
            title: topic.displayName,
            description: topic.summary
          )
        }
      }
      .drive(topicItems)
      .disposed(by: bag)

    service.collections
      .asLoadingStateDriver()
      .map { collections -> [Item] in
        collections.map { collection -> Item in
          Item(
            logoLocalURL: collection.logoLocalURL,
            title: collection.displayName,
            description: collection.description
          )
        }
      }
      .drive(collectionItems)
      .disposed(by: bag)
  }

}

// MARK: - Types

extension ExploreModel {

  struct Item {
    let logoLocalURL: URL?
    let title: String
    let description: String
  }

}
