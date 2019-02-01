import UIKit

import RxDataSources

import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

class LanguagesFlowLayout: UICollectionViewLayout {

  let scheduler = SerialDispatchQueueScheduler(qos: .userInteractive)

  // MARK: - Layout

  private struct LayoutResult {
    let headers: [UICollectionViewLayoutAttributes]
    let cells: [[UICollectionViewLayoutAttributes]]
    let contentSize: CGSize

    var all: [UICollectionViewLayoutAttributes] {
      return headers + cells.flatMap { $0 }
    }
  }

  private var cache: LayoutResult?

  /// Calculate all layout attributes for input `data`, and store them
  /// in the `cache` property.
  ///
  /// - Parameter data: The sectino model array from which to calculate
  ///   the layouts.
  func calculateLayouts(data: [SectionModel<String, String>]) {
    // swiftlint:disable:previous function_body_length

    // Metrics
    let width = UIScreen.main.bounds.width

    let cellHeight: CGFloat = 24

    let itemGap: CGFloat = 8
    let rowGap: CGFloat = 8
    let sectionGap: CGFloat = 8

    let headerLeftMargin: CGFloat = 16
    let headerHeight: CGFloat = 24

    let sectionInset = UIEdgeInsets(top: 10, left: 16 + 8, bottom: 10, right: 16)

    var x: CGFloat = 0
    var y: CGFloat = 0

    var headers = [UICollectionViewLayoutAttributes]()
    var cells = [[UICollectionViewLayoutAttributes]]()

    for (sectionIndex, section) in data.enumerated() {
      let languages = section.items

      // Header

      x = headerLeftMargin
      if sectionIndex == 0 {
        y = sectionGap
      } else {
        y += sectionGap
      }

      let frame = CGRect(x: x, y: y, width: 200, height: headerHeight)
      let header = UICollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        with: .init(item: 0, section: sectionIndex)
      )
      header.frame = frame

      // Cells

      x = sectionInset.left
      y += headerHeight + sectionInset.top

      let attrs = languages.enumerated().map {
        itemIndex, language -> UICollectionViewLayoutAttributes in

        var frame = CGRect(origin: .init(x: x, y: y), size: LanguagesController.Cell.cellSize(for: language))
        if frame.maxX > width - sectionInset.right {
          x = sectionInset.left
          y += cellHeight + rowGap
          frame.origin = .init(x: x, y: y)
        }

        x = frame.maxX + itemGap

        let attr = UICollectionViewLayoutAttributes(forCellWith: .init(item: itemIndex, section: sectionIndex))
        attr.frame = frame

        return attr
      }

      // Last row of the section
      if !attrs.isEmpty {
        y += cellHeight + sectionInset.bottom
      }

      headers.append(header)
      cells.append(attrs)
    }

    let contentSize = CGSize(width: width, height: y + cellHeight + sectionInset.bottom)

    cache = LayoutResult(headers: headers, cells: cells, contentSize: contentSize)
  }

//  override func prepare() {
//  }

  // MARK: - UICollectionViewLayout

  override var collectionViewContentSize: CGSize {
    return cache?.contentSize ?? .zero
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attrs = cache?.all.filter {
      $0.frame.intersects(rect)
    }

    return attrs
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache?.cells[indexPath.section][indexPath.item]
  }

  override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes?
  {
    assert(elementKind == UICollectionView.elementKindSectionHeader)
    return cache?.headers[indexPath.section]
  }

  // MARK: - Moving Pinned Items

  override func targetIndexPath(
    forInteractivelyMovingItem previousIndexPath: IndexPath,
    withPosition position: CGPoint
  )
    -> IndexPath
  {
    let indexPath = super.targetIndexPath(
      forInteractivelyMovingItem: previousIndexPath, withPosition: position
    )

    guard let cache = cache else {
      return indexPath
    }

    let minY = cache.headers[1].frame.maxY
    let maxY = cache.headers[2].frame.minY

    if position.y < minY {
      return .init(item: 0, section: 1)
    } else if position.y > maxY {
      let count = cache.cells[1].count
      return .init(item: count - 1, section: 1)
    } else {
      return indexPath
    }
  }

  override func layoutAttributesForInteractivelyMovingItem(
    at indexPath: IndexPath,
    withTargetPosition position: CGPoint
  )
    -> UICollectionViewLayoutAttributes
  {
    guard let cache = cache else {
      return super.layoutAttributesForInteractivelyMovingItem(
        at: indexPath, withTargetPosition: position
      )
    }

    let attr = cache.cells[indexPath.section][indexPath.item]
    attr.center = position
    jack.func().debug("frame: \(attr.frame)")
    return attr
  }

}
