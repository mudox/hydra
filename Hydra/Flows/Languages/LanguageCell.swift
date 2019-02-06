import UIKit

import RxCocoa
import RxSwift

import SnapKit

import MudoxKit

extension LanguagesController {

  class Cell: CollectionCell {

    // MARK: Metric

    static let cellHeight: CGFloat = 24

    static func size(for language: String) -> CGSize {
      let containingSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
      let options: NSStringDrawingOptions = []
      let attributes: [NSAttributedString.Key: Any]? = [
        .font: labelFont
      ]
      let context: NSStringDrawingContext? = nil

      let width = (language as NSString).boundingRect(
        with: containingSize,
        options: options,
        attributes: attributes,
        context: context
      ).size.width.rounded(.up)

      return .init(width: width + cellHeight, height: cellHeight)
    }

    // MARK: - Setup View

    let label = UILabel()

    static let labelFont = UIFont.text

    override func setupView() {
      backgroundColor = .bgDark

      layer.do {
        $0.masksToBounds = true
        $0.cornerRadius = LanguagesController.Cell.cellHeight / 2
      }

      setupLabel()
    }

    func setupLabel() {
      label.do {
        $0.textAlignment = .center
        $0.font = LanguagesController.Cell.labelFont
        $0.textColor = .black
      }

      contentView.addSubview(label)
      label.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }
    }

    // MARK: - Show

    override var isSelected: Bool {
      didSet {
        if isSelected {
          label.textColor = .white
          backgroundColor = .brand
        } else {
          label.textColor = .black
          backgroundColor = .bgDark
        }
      }
    }

    func show(language: String) {
      label.text = language
    }

  }

}
