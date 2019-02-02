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

// MARK: - Select Element of Specific Type

func button(withTitle title: String) -> GREYInteraction {
  return element(ofType: UIButton.self, withLabel: title)
}

func label(shows title: String) -> GREYInteraction {
  return element(ofType: UILabel.self, hasText: title)
}

// MARK: - Select using custom matcher

var selectedCollectionViewCell: GREYInteraction {
  let matcher = GREYElementMatcherBlock(
    matchesBlock: { anyObject -> Bool in
      if
        let cell = anyObject as? UICollectionViewCell,
        cell.isSelected == true
      {
        return true
      } else {
        return false
      }
  },
    descriptionBlock: { desc in
      desc.appendText("UICollectionViewCell that is selected")
  }
  )
  
  return EarlGrey.selectElement(with: matcher)
}

var selectedTableViewCell: GREYInteraction {
  let matcher = GREYElementMatcherBlock(
    matchesBlock: { anyObject -> Bool in
      if
        let cell = anyObject as? UITableViewCell,
        cell.isSelected == true
      {
        return true
      } else {
        return false
      }
  },
    descriptionBlock: { desc in
      desc.appendText("UITableViewCell that is selected")
  }
  )
  
  return EarlGrey.selectElement(with: matcher)
}

