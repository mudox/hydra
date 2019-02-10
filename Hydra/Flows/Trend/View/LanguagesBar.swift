import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import SnapKit

import JacKit
import MudoxKit

private let jack = Jack().set(format: .short)

class LanguagesBar: View {

  override init() {
    selection = Driver.combineLatest(
      items.asDriver().skip(1),
      index.asDriver().skip(1)
    ) { ($1, $0[$1]) }

    super.init()

    setupView()
    setupBinding()
  }

  // MARK: - Subviews

  private var collectionView: UICollectionView!

  var moreButton: UIButton!

  private var underline: UIView!

  // MARK: - Constants

  private static let height: CGFloat = 24
  private static let underLineHeight: CGFloat = 2

  // MARK: - View

  override func setupView() {
    snp.makeConstraints { make in
      make.height.equalTo(LanguagesBar.height)
      make.width.greaterThanOrEqualTo(200)
    }

    setupCollectionView()
    setupMoreButton()
  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 4
      $0.estimatedItemSize = CGSize(width: 120, height: LanguagesBar.height)
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        LanguagesBar.Cell.self,
        forCellWithReuseIdentifier: LanguagesBar.Cell.identifier
      )

      $0.aid = .languagesBarCollectionView
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

      $0.aid = .languagesBarMoreButton
    }

    addSubview(moreButton)
    moreButton.snp.makeConstraints { make in
      make.top.bottom.trailing.equalToSuperview()
      make.leading.equalTo(collectionView.snp.trailing).offset(10)
    }
  }

  func setupUnderline(cell: LanguagesBar.Cell) {
    underline = UIView().then {
      $0.isUserInteractionEnabled = false
      $0.backgroundColor = .dark
      $0.layer.cornerRadius = LanguagesBar.underLineHeight / 2
    }
    collectionView.addSubview(underline)
  }

  func updateUnderlineLayout(to cell: LanguagesBar.Cell) {
    let centerX = cell.frame.midX
    let width = max(8, cell.bounds.width / 3)

    underline.snp.remakeConstraints { make in
      make.centerX.equalTo(centerX)
      make.width.equalTo(width)
      make.bottom.equalTo(cell)
      make.height.equalTo(LanguagesBar.underLineHeight)
    }

    underline.superview?.layoutIfNeeded()
  }

  // MARK: - Binding

  let index = BehaviorRelay<Int>(value: 0)

  let items = BehaviorRelay<[String]>(value: ["<Should Be Skipped>"])

  let selection: Driver<(index: Int, item: String)>

  override func setupBinding() {

    // Drive collection view items

    items.asDriver().skip(1)
      .drive(collectionView.rx.items)(setupCell)
      .disposed(by: bag)

    // Selection drives cell highlighting

    collectionView.rx.itemSelected
      .map { $0.item }
      .bind(to: index)
      .disposed(by: bag)

    index.asDriver().skip(1)
      .drive(onNext: { [weak self] index in
        guard let self = self else { return }
        // Avoid to be run at the same run loop of the items reload
        DispatchQueue.main.async {
          self.selectItem(at: index)
        }
      })
      .disposed(by: bag)

    TrendModel.color.asDriver()
      .drive(onNext: { [weak self] in
        self?.underline?.backgroundColor = $0
      })
      .disposed(by: bag)
  }

  func selectItem(at index: Int) {
    let indexPath = IndexPath(item: index, section: 0)

    guard let cell = self.collectionView.cellForItem(at: indexPath) as? Cell else {
      jack.func().warn("Failed to get cell collection view")
      return
    }

    // Select item

    collectionView.selectItem(
      at: indexPath, animated: true,
      scrollPosition: .centeredHorizontally
    )

    // Update underline

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

}

// MARK: - Helpers

private func setupCell(view: UICollectionView, index: Int, language: String) -> UICollectionViewCell {
  let indexPath = IndexPath(item: index, section: 0)
  let cell = view.dequeueReusableCell(
    withReuseIdentifier: LanguagesBar.Cell.identifier, for: indexPath
  ) as! LanguagesBar.Cell // swiftlint:disable:this force_cast

  cell.label.text = language
  return cell
}

// MARK: - LanguageBar.Cell

extension LanguagesBar {

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
        make.height.equalTo(LanguagesBar.height)
      }
    }

    override var isSelected: Bool {
      didSet {
        label.textColor = isSelected ? .dark : .light
      }
    }

  }

}
