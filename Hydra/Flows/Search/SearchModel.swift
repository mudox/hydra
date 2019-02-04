import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol SearchModelInput {

}

protocol SearchModelOutput {

}

protocol SearchModelType: SearchModelInput, SearchModelOutput {}

extension SearchModelType {
  var input: SearchModelInput { return self }
  var output: SearchModelOutput { return self }
}

// MARK: - View Model

class SearchModel: ViewModel, SearchModelType {

  // MARK: Types

  // MARK: Input

  // MARK: Output

  // MARK: Binding

  required override init() {

  }

}
