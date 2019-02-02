import UIKit

import RxDataSources

import RxSwift

import JacKit

private let jack = Jack().set(format: .short)

class LanguagesFlowLayout: UICollectionViewLayout {

//  let scheduler = SerialDispatchQueueScheduler(qos: .userInteractive)

  // MARK: - Metrics

  let width = UIScreen.main.bounds.width

  let cellHeight: CGFloat = 24

  let itemGap: CGFloat = 8
  let rowGap: CGFloat = 8
  let sectionGap: CGFloat = 8

  let headerLeftMargin: CGFloat = 16
  let headerHeight: CGFloat = 24

  let sectionInset = UIEdgeInsets(top: 10, left: 16 + 8, bottom: 10, right: 16)

  // MARK: - Layout & Cache

  private var cache: LayoutResult?

  /// Calculate all layout attributes for input `data`, and store them
  /// in the `cache` property.
  ///
  /// - Parameter data: The sectino model array from which to calculate
  ///   the layouts.
  func calculateLayouts(data: [SectionModel<String, String>]) {
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
        (itemIndex: Int, language: String) -> UICollectionViewLayoutAttributes in

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

  // MARK: - Provide Basic Layout

  override var collectionViewContentSize: CGSize {
    return cache?.contentSize ?? .zero
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let cache = cache else { return nil }

    var allCellLayouts: [UICollectionViewLayoutAttributes]
    if let moveController = pinnedItemMovingController {
      allCellLayouts = cache.cells[0] + moveController.allPinnedItemLayouts + cache.cells[2]
    } else {
      allCellLayouts = cache.all
    }

    return allCellLayouts.filter {
      $0.frame.intersects(rect)
    }
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

  private var pinnedItemMovingController: PinnedItemMovingController?

  func startMovingPinnedItem(at indexPath: IndexPath) {
    // `pinnedItemMovingController` may be non-nil here, because user may long press
    // the item without move enough distance to trigger moving.
    pinnedItemMovingController = PinnedItemMovingController(layout: self, for: indexPath.item)
  }

  func endMovingPinnedItem() {
    assert(pinnedItemMovingController != nil)
    pinnedItemMovingController = nil
  }

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

    let targetIndexPath: IndexPath

    if position.y < minY {
      targetIndexPath = .init(item: 0, section: 1)
    } else if position.y > maxY {
      let count = cache.cells[1].count
      targetIndexPath = .init(item: count - 1, section: 1)
    } else {
      targetIndexPath = indexPath
    }

    return targetIndexPath
  }

  override func layoutAttributesForInteractivelyMovingItem(
    at indexPath: IndexPath,
    withTargetPosition position: CGPoint
  )
    -> UICollectionViewLayoutAttributes
  {
    assert(indexPath.section == 1)

    guard cache != nil else {
      return super.layoutAttributesForInteractivelyMovingItem(
        at: indexPath, withTargetPosition: position
      )
    }

    pinnedItemMovingController!.hoveringIndex = indexPath.item
    let attr = pinnedItemMovingController!.layoutAttributesForMovingItem(withPosition: position)
    assert(attr.indexPath == indexPath)
    return attr
  }

}

// MARK: - Types

fileprivate extension LanguagesFlowLayout {

  struct LayoutResult {

    let headers: [UICollectionViewLayoutAttributes]
    let cells: [[UICollectionViewLayoutAttributes]]
    let contentSize: CGSize

    var all: [UICollectionViewLayoutAttributes] {
      return headers + cells.flatMap { $0 }
    }

  }

  class PinnedItemMovingController {

    weak var layout: LanguagesFlowLayout!

    let sourceIndex: Int
    var hoveringIndex: Int

    init(layout: LanguagesFlowLayout, for index: Int) {
      self.layout = layout

      sourceIndex = index
      hoveringIndex = index
    }

    var allPinnedItemLayouts: [UICollectionViewLayoutAttributes] {
      var sizes = layout.cache!.cells[1].map { $0.size }
      sizes.insert(sizes.remove(at: sourceIndex), at: hoveringIndex)

      let origin = layout.cache!.cells[1].first!.frame.origin
      var x = origin.x
      var y = origin.y

      let maxX = UIScreen.main.bounds.width - layout.sectionInset.right

      // Re-layout pinned section according hovering index
      return sizes.enumerated().map {
        pair -> UICollectionViewLayoutAttributes in
        let (index, size) = pair

        var frame = CGRect(origin: .init(x: x, y: y), size: size)
        if frame.maxX > maxX {
          x = layout.sectionInset.left
          y += layout.cellHeight + layout.rowGap
          frame.origin = .init(x: x, y: y)
        }

        x = frame.maxX + layout.itemGap

        let attr = UICollectionViewLayoutAttributes(forCellWith: .init(item: index, section: 1))
        attr.frame = frame

        return attr
      }
    }

    func layoutAttributesForMovingItem(withPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
      let attr = allPinnedItemLayouts[hoveringIndex]
      attr.center = position
      return attr
    }

  }

}
