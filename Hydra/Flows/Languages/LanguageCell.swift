import UIKit

import RxCocoa
import RxSwift

import SnapKit

extension LanguagesController {

  class Cell: UICollectionViewCell {

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      fatalError("do not use it")
    }

    override init(frame: CGRect) {
      super.init(frame: .zero)
      setupView()
    }

    // MARK: - Metric

    static let cellHeight: CGFloat = 24

    static func cellSize(for language: String) -> CGSize {
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

    // MARK: - Subviews

    let label = UILabel()

    // MARK: - Setup

    static let labelFont = UIFont.text

    func setupView() {
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

    // MARK: - Model

    var disposeBag = DisposeBag()

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
