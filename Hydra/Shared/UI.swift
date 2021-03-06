import SwiftHEXColors

import SnapKit

extension CGFloat {

  static let margin: CGFloat = 8

  static let cornerRadius: CGFloat = 4

}

extension UIFont {

  static let title = UIFont.systemFont(ofSize: 14, weight: .bold)
  static let text = UIFont.systemFont(ofSize: 12)
  static let callout = UIFont.systemFont(ofSize: 10)

}

extension UIColor {

  // Foreground
  static let brand = #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)

  static let dark = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
  static let light = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)

  // Background

  /// Used as root view backgroiund of view controllers
  static let bgDark = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
  /// Used as card background
  static let bgLight = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

  // Empty dataset
  static let emptyLight = #colorLiteral(red: 0.9101999158, green: 0.9101999158, blue: 0.9101999158, alpha: 1)
  static let emptyDark = #colorLiteral(red: 0.7200226663, green: 0.7200226663, blue: 0.7200226663, alpha: 1)

}
