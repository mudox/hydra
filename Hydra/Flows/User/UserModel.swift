import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import MudoxKit

import JacKit

private let jack = Jack().set(format: .short)

// MARK: Interface

protocol UserModelInput {

}

protocol UserModelOutput {

}

protocol UserModelType: UserModelInput, UserModelOutput {}

extension UserModelType {
  var input: UserModelInput { return self }
  var output: UserModelOutput { return self }
}

// MARK: - View Model

class UserModel: ViewModel, UserModelType {

  // MARK: Types

  // MARK: Input

  // MARK: Output

  // MARK: Binding

  required override init() {

  }

}
