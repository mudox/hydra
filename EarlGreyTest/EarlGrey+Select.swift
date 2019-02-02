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

func element(
  ofType type: AnyClass? = nil,
  withLabel label: String? = nil,
  hasText text: String? = nil,
  visible: Bool? = nil
)
  -> GREYInteraction
{
  var matchers = [GREYMatcher]()

  if let type = type {
    matchers.append(grey_kindOfClass(type))
  }

  if let label = label {
    matchers.append(grey_accessibilityLabel(label))
  }

  if let text = text {
    matchers.append(grey_text(text))
  }

  if let visible = visible {
    if visible {
      matchers.append(grey_sufficientlyVisible())
    } else {
      matchers.append(grey_notVisible())
    }
  }

  return EarlGrey.selectElement(with: grey_allOf(matchers))
}

func button(withTitle title: String) -> GREYInteraction {
  return element(ofType: UIButton.self, withLabel: title)
}

func label(shows title: String) -> GREYInteraction {
  return element(ofType: UILabel.self, hasText: title)
}
