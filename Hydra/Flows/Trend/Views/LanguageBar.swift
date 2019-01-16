import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

class LanguageBar: UIView {

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  init() {
    super.init(frame: .zero)

    setupView()
    setupModel()
  }

  // MARK: - Subviews

  private var collectionView: UICollectionView!

  var moreButton: UIButton!

  private var underline: UIView!

  // MARK: - Metrics

  private static let height: CGFloat = 24
  private static let underLineHeight: CGFloat = 2

  // MARK: - Setup View

  func setupView() {
    snp.makeConstraints { make in
      make.height.equalTo(LanguageBar.height)
      make.width.greaterThanOrEqualTo(200)
    }

    setupCollectionView()
    setupMoreButton()
  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 4
      $0.estimatedItemSize = CGSize(width: 120, height: LanguageBar.height)
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        LanguageBar.Cell.self,
        forCellWithReuseIdentifier: LanguageBar.Cell.identifier
      )
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.bottom.leading.equalToSuperview()
    }
  }

  func setupMoreButton() {
    moreButton = UIButton().then {
      $0.setTitle("More", for: .normal)
      $0.setTitleColor(.brand, for: .normal)
      $0.titleLabel?.font = .text
    }

    addSubview(moreButton)
    moreButton.snp.makeConstraints { make in
      make.top.bottom.trailing.equalToSuperview()
      make.leading.equalTo(collectionView.snp.trailing).offset(10)
    }
  }

  func setupUnderline(cell: LanguageBar.Cell) {
    underline = UIView().then {
      $0.isUserInteractionEnabled = false
      $0.backgroundColor = .dark
      $0.layer.cornerRadius = LanguageBar.underLineHeight / 2
    }
    collectionView.addSubview(underline)
  }

  func updateUnderlineLayout(to cell: LanguageBar.Cell) {
    let centerX = cell.frame.midX
    let width = max(8, cell.bounds.width / 3)

    underline.snp.remakeConstraints { make in
      make.centerX.equalTo(centerX)
      make.width.equalTo(width)
      make.bottom.equalTo(cell)
      make.height.equalTo(LanguageBar.underLineHeight)
    }

    underline.superview?.layoutIfNeeded()
  }

  func highlight(_ cell: LanguageBar.Cell) {
    if underline == nil {
      setupUnderline(cell: cell)
      updateUnderlineLayout(to: cell)
      return
    }

    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 2,
      options: [],
      animations: { self.updateUnderlineLayout(to: cell) }
    )
  }

  // MARK: - View Model

  private let disposeBag = DisposeBag()

  // MARK: Input

  let languages = BehaviorRelay<[String]>(value: [])

  let selectedIndexPath = BehaviorRelay<IndexPath>(value: .init(item: 0, section: 0))

  // MARK: Output

  var selectedLanguage: Driver<String>!

  func setupModel() {

    let indexPath = selectedIndexPath.asDriver().skip(1)
    let items = languages.asDriver().skip(1)

    selectedLanguage = indexPath.withLatestFrom(items) { $1[$0.item] }

    disposeBag.insert(
      collectionView.rx.itemSelected.bind(to: selectedIndexPath),
      items.drive(collectionView.rx.items)(setupCell),
      items.mapTo(IndexPath(item: 0, section: 0)).drive(selectedIndexPath)
    )

    indexPath
      .drive(onNext: { [weak self] indexPath in
        DispatchQueue.main.async { // In case the cell is not shown in current run loop
          guard let self = self else { return }
          guard let cell = self.collectionView.cellForItem(at: indexPath) as? LanguageBar.Cell else {
            jack.warn("`self.collectionView.cellForItem(at: \(indexPath)) as? LanguageBar.Cell` returned nil")
            return
          }
          self.highlight(cell)
        }
      })
      .disposed(by: disposeBag)
  }

}

let setupCell = {
  (view: UICollectionView, index: Int, language: String) -> UICollectionViewCell in

  let indexPath = IndexPath(item: index, section: 0)
  let cell = view.dequeueReusableCell(
    withReuseIdentifier: LanguageBar.Cell.identifier, for: indexPath
  ) as! LanguageBar.Cell // swiftlint:disable:this force_cast

  cell.label.text = language
  return cell
}

// MARK: - LanguageBar.Cell

extension LanguageBar {

  class Cell: UICollectionViewCell {

    static let identifier = "\(type(of: self))"

    var label: UILabel!

    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
      super.init(frame: frame)

      label = UILabel().then {
        $0.textColor = .light
        $0.font = .text
        $0.textAlignment = .center
      }

      contentView.addSubview(label)
      label.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(6)
        make.top.bottom.equalToSuperview()
        make.height.equalTo(LanguageBar.height)
      }
    }

    override var isSelected: Bool {
      didSet {
        label.textColor = isSelected ? .dark : .light
      }
    }

  }

}
