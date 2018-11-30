import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

private let barHeight: CGFloat = 34

class LanguageBar: UIView {

  typealias Language = String

  var languagesRelay: BehaviorRelay<[Language]>!
  private var languages: Driver<[Language]>!

  private var selectedIndexPathRelay: BehaviorRelay<IndexPath>!
  private var selectedIndexPath: Driver<IndexPath>!

  var selectedLanguage: Driver<Language>!

  // MARK: - Subviews

  private var collectionView: UICollectionView!
  private var underline: UIView!

  // MARK: - View

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  init() {
    super.init(frame: .zero)

    snp.makeConstraints { make in
      make.height.equalTo(barHeight)
      make.width.greaterThanOrEqualTo(200)
    }

    setupCollectionView()
    setupBindings()
  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .horizontal
      $0.minimumLineSpacing = 4
      $0.estimatedItemSize = CGSize(width: 120, height: barHeight)
      $0.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
      $0.backgroundColor = .clear
      $0.clipsToBounds = false

      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false

      $0.register(
        LanguageBar.Cell.self,
        forCellWithReuseIdentifier: LanguageBar.Cell.identifier
      )
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setupUnderline(cell: LanguageBar.Cell) {
    underline = UIView().then {
      $0.isUserInteractionEnabled = false
      $0.backgroundColor = .dark
      $0.layer.cornerRadius = UI.underlineHeight / 2
    }
    collectionView.addSubview(underline)
  }

  func moveUnderline(to cell: LanguageBar.Cell) {
    let layoutUnderline = { [weak self] in
      guard let self = self else { return }

      let centerX = cell.frame.midX
      let width = max(8, cell.bounds.width / 3)

      self.underline.snp.remakeConstraints { make in
        make.centerX.equalTo(centerX)
        make.width.equalTo(width)
        make.top.equalTo(cell.snp.bottom)
        make.height.equalTo(UI.underlineHeight)
      }

      self.underline.superview?.layoutIfNeeded()
    }

    if underline == nil {
      setupUnderline(cell: cell)
      layoutUnderline()
      return
    }

    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 2,
      options: [],
      animations: layoutUnderline
    )
  }

  // MARK: - Bindings

  private var disposeBag = DisposeBag()

  func setupBindings() {
    setupProperties()

    // Reload collection view on new data arrival
    languages
      .drive(collectionView.rx.items)(setupCell)
      .disposed(by: disposeBag)

    // Scroll & select first item after reloading
    languages
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }

        DispatchQueue.main.async {
          let indexPath = IndexPath(item: 0, section: 0)
          self.collectionView.scrollToItem(
            at: indexPath,
            at: .left,
            animated: false
          )
          self.collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .left
          )
          self.selectedIndexPathRelay.accept(indexPath)
        }
      })
      .disposed(by: disposeBag)

    // Underline follows selected cell with spring animation
    selectedIndexPath
      .drive(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        DispatchQueue.main.async { // In case the cell is not shown in current run loop
          if let cell = self.collectionView.cellForItem(at: indexPath)
            as? LanguageBar.Cell {
            self.moveUnderline(to: cell)
          }
        }
      })
      .disposed(by: disposeBag)
  }

  func setupProperties() {
    languagesRelay = .init(value: [])
    languages = languagesRelay
      .skip(1)
      .do(onNext: {
        if $0.isEmpty {
          jack.descendant("languages")
            .failure("input languages set should not be empty")
        }
      })
      .asDriver()

    selectedIndexPathRelay = .init(value: IndexPath(item: 0, section: 0))
    selectedIndexPath = Driver.merge(
      collectionView.rx.itemSelected.asDriver(),
      selectedIndexPathRelay.asDriver()
    )

    selectedLanguage = selectedIndexPath.withLatestFrom(languages) { indexPath, languages -> Language in
      languages[indexPath.item]
    }
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

extension LanguageBar {

  class Cell: UICollectionViewCell {

    static let identifier = "\(type(of: self))"

    var label: UILabel!

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      fatalError("do not use it")
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
        make.height.equalTo(barHeight)
      }
    }

    override var isSelected: Bool {
      didSet {
        label.textColor = isSelected ? .dark : .light
      }
    }

  }

}
