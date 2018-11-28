import SwiftHEXColors

// swiftlint:disable:next type_name
enum UI {

  // Layout
  static let margin = 8
  static let spacing = 10

  // Shadow

  /// Set to 0 to disable app shadows (default: 0.2)
  static let shadowOpacity: Float = 0
  static let shadowOffset = CGSize(width: 0, height: 0)
  static let shadowRadius: CGFloat = 4
  static let shadowColor: UIColor = .black

  // Shape

  static let cornerRadius: CGFloat = 4
}

extension UIFont {

  static let title: UIFont = .systemFont(ofSize: 20, weight: .bold)
  static let text: UIFont = .systemFont(ofSize: 14)
  static let callout: UIFont = .systemFont(ofSize: 10)

}

extension UIColor {

  // Foreground

  static let highlight = UIColor(hex: 0xF5A623)!
  static let dark = UIColor(hex: 0x4A4A4A)!
  static let light = UIColor(hex: 0x9B9B9B)!

  // Background

  static let backDark: UIColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
  static let backLight: UIColor = .white

  // Empty dataset

  static let emptyLight = #colorLiteral(red: 0.9101999158, green: 0.9101999158, blue: 0.9101999158, alpha: 1)
  static let emptyDark = #colorLiteral(red: 0.7200226663, green: 0.7200226663, blue: 0.7200226663, alpha: 1)

}
