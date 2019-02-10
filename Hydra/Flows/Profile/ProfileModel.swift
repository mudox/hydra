import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol ProfileModelInput {

}

protocol ProfileModelOutput {

}

protocol ProfileModelType: ProfileModelInput, ProfileModelOutput {}

extension ProfileModelType {
  var input: ProfileModelInput { return self }
  var output: ProfileModelOutput { return self }
}

// MARK: - View Model

class ProfileModel: ViewModel, ProfileModelType {

  // MARK: Types

  // MARK: Input

  // MARK: Output

  // MARK: Binding

  required override init() {

  }

}
