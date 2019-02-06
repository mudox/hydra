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

}

protocol ExploreModelType: ExploreModelInput, ExploreModelOutput {}

extension ExploreModelType {
  var input: ExploreModelInput { return self }
  var output: ExploreModelOutput { return self }
}

// MARK: - View Model

class ExploreModel: ViewModel, ExploreModelType {

  // MARK: Types

  // MARK: Input

  // MARK: Output

  // MARK: Binding

  required override init() {
// MARK: - Types

extension ExploreModel {

  struct Item {
    let logoLocalURL: URL?
    let title: String
    let description: String
  }

}
