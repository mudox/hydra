import XCTest

import Nimble
import Quick

import GitHub

import MBProgressHUD

@testable import MudoxKit

@testable import Hydra

import EarlGrey

func element(withAID id: AID) -> GREYInteraction {
  return EarlGrey.selectElement(with: grey_accessibilityID(id.rawValue))
}

func element(withLabel label: String) -> GREYInteraction {
  return EarlGrey.selectElement(with: grey_accessibilityLabel(label))
}


/// Include uibutton embeded within UIBarButtonItem
///
/// - Parameter title: Title of the button.
/// - Returns: GREYInteraction to act and assert against.
func button(withTitle title: String) -> GREYInteraction {
  return EarlGrey.selectElement(with: grey_buttonTitle(title))
}
