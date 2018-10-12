import UIKit

import RxCocoa
import RxSwift

import JacKit

private let jack = Jack("BaseFlow")

class BaseFlow: Hashable {

  var disposeBag = DisposeBag()

  let identifier = "BaseFlow"

  /// The root node of the view controller tree under it manages.
  var viewController: UIViewController!

  weak var parentFlow: BaseFlow?

  var childFlows: Set<BaseFlow> = []

  /// Transition to a sub-flow.
  ///
  /// - Parameter subflow: The sub-flow to take over the screen.
  func transition(to flow: BaseFlow) {
    fatalError("Abstract member, need to be overriden by subclassses")
  }

  /// Dismiss a child flow or current flow from its parent flow.
  ///
  /// - Parameter flow: If not nil, remove the given child flow. If nil dismiss
  ///   current flow from its parent flow.
  func dismiss(_: BaseFlow?) {
    fatalError("Abstract member, need to be overriden by subclassses")
  }

  /// Add new child flow.
  ///
  /// - Parameter flow: The child flow to add into `childFlows`.
  func addChild(_ flow: BaseFlow) {
    if childFlows.contains(flow) {
      jack.descendant("addChild")
        .warn("flow \(type(of: flow)) already in `childFlows`")
    } else {
      flow.parentFlow = self
      childFlows.insert(flow)
    }
  }

  /// Remove a child flow.
  ///
  /// - Parameter flow: The child flow to remove from `childFlows`.
  func removeChild(_ flow: BaseFlow) {
    flow.parentFlow = nil
    childFlows.remove(flow)
  }

  // MARK: - Equatable & Hashable

  static func == (left: BaseFlow, right: BaseFlow) -> Bool {
    return left === right
  }

  var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
}
