//
//  SpotCollectionViewFlowLayout.swift
//  DaihugouBattle
//
//  Created by main on 2018/12/07.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class SpotCollectionViewFlowLayout: UICollectionViewFlowLayout{
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var elements =  super.layoutAttributesForElements(in: rect),
            let collectionView = self.collectionView else{
            return nil
        }

        for layoutAttributes in elements{
            if layoutAttributes.representedElementKind == UICollectionView.elementKindSectionHeader{
                let section = layoutAttributes.indexPath.section
                let numberOfItemsInSection = collectionView.numberOfItems(inSection: section)
                let firstCellIndexPath = IndexPath(row: 0, section: section)
                let firstCellAttrs = self.layoutAttributesForItem(at: firstCellIndexPath)!
                let headerWidth = firstCellAttrs.bounds.width
                let headerHeight = collectionView.bounds.height - firstCellAttrs.bounds.height * 0.8
                let size = CGSize(width: headerWidth, height: headerHeight)
                var origin = layoutAttributes.frame.origin
                origin.y = 0
                layoutAttributes.zIndex = 1024
                layoutAttributes.frame = CGRect(origin: origin, size: size)
                dump(layoutAttributes.frame)
                
                for row in 0 ..< numberOfItemsInSection{
                    let attrs = layoutAttributesForItem(at: IndexPath(row: row, section: section))
                    attrs?.center.x -= headerWidth
                    print("famefeim:om")
                    dump(attrs?.frame)
                }
            }
        }
        
        return elements
    }
}
