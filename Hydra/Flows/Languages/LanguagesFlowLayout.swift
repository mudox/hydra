import UIKit

import RxSwift

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

  func layout(for sections: [LanguagesSection], width: CGFloat) {

    // Metrics
    let cellHeight: CGFloat = 24

    let itemGap: CGFloat = 8
    let rowGap: CGFloat = 8
    let sectionGap: CGFloat = 8

    let headerLeftMargin: CGFloat = 16
    let headerHeight: CGFloat = 24

    let sectionInset = UIEdgeInsets(top: 10, left: 16 + 8, bottom: 10, right: 16)

    var x: CGFloat = 0
    var y: CGFloat = 0

    func attributes(for languages: [String], inSection section: Int)
      -> (header: UICollectionViewLayoutAttributes, cells: [UICollectionViewLayoutAttributes])
    {
      // Header
      x = headerLeftMargin
      if section == 0 {
        y = sectionGap
      } else {
        y += sectionGap
      }

      let frame = CGRect(x: x, y: y, width: 200, height: headerHeight)
      let header = UICollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        with: .init(item: 0, section: section)
      )
      header.frame = frame

      // Cells

      x = sectionInset.left
      y += headerHeight + sectionInset.top

      let cells = languages.enumerated().map {
        index, language -> UICollectionViewLayoutAttributes in

        var frame = CGRect(origin: .init(x: x, y: y), size: LanguageCell.cellSize(for: language))
        if frame.maxX > width - sectionInset.right {
          x = sectionInset.left
          y += cellHeight + rowGap
          frame.origin = .init(x: x, y: y)
        }

        x = frame.maxX + itemGap

        let attr = UICollectionViewLayoutAttributes(forCellWith: .init(item: index, section: section))
        attr.frame = frame

        return attr
      }

      // Last row of the section
      if cells.isEmpty {

      } else {
      y += cellHeight + sectionInset.bottom
      }

      return (header, cells)
    }

    let all = sections.enumerated().map { attributes(for: $0.element.items, inSection: $0.offset) }

    let headers = all.map { $0.header }
    let cells = all.map { $0.cells }
    let contentSize = CGSize(width: width, height: y + cellHeight + sectionInset.bottom)

    cache = LayoutResult(headers: headers, cells: cells, contentSize: contentSize)
  }

  // MARK: - UICollectionViewLayout

  override var collectionViewContentSize: CGSize {
    return cache?.contentSize ?? .zero
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return cache?.all.filter {
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

}
