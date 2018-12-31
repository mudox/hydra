import UIKit

import RxCocoa
import RxSwift
import RxSwiftExt

import SnapKit

import JacKit

private let jack = Jack().set(format: .short)

private let barHeight: CGFloat = 24

class LanguageBar: UIView {

  typealias Language = String

  var languages: [Language] {
    get {
      return _languagesRelay.value
    }
    set {
      _languagesRelay.accept(newValue)
    }
  }

  private let _languagesRelay = BehaviorRelay<[Language]>(value: [])
  private let _languagesDriver: Driver<[Language]>

  private let _indexPathRelay = BehaviorRelay<IndexPath>(value: .init(item: 0, section: 0))
  private let _indexPathDriver: Driver<IndexPath>

  let selectedLanguage: Driver<Language>

  // MARK: - Subviews

  private var collectionView: UICollectionView!
  private var underline: UIView!

  // MARK: - View

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("do not use it")
  }

  init() {
    _languagesDriver = _languagesRelay
      .asDriver()
      .skip(1)
      .do(onNext: {
        jack.assert(!$0.isEmpty, "Languages list should not be empty")
      })

    _indexPathDriver = _indexPathRelay.asDriver().skip(1)

    selectedLanguage = _indexPathDriver
      .withLatestFrom(_languagesDriver) { indexPath, languages -> Language in
        languages[indexPath.item]
      }

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
      $0.layer.cornerRadius = .lineHeight / 2
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
        make.height.equalTo(CGFloat.lineHeight)
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

    collectionView.rx.itemSelected.bind(to: _indexPathRelay)
      .disposed(by: disposeBag)

    // Reload collection view on new data arrival
    _languagesDriver
      .drive(collectionView.rx.items)(setupCell)
      .disposed(by: disposeBag)

    // Scroll & select first item after reloading
    _languagesDriver
      .mapTo(IndexPath(item: 0, section: 0))
      .do(onNext: { [weak self] indexPath in
        guard let self = self else { return }

        DispatchQueue.main.async { [weak self] in
          self?.collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .left
          )
        }
      })
      .drive(_indexPathRelay)
      .disposed(by: disposeBag)

    // Underline follows selected cell with spring animation
    _indexPathDriver
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
