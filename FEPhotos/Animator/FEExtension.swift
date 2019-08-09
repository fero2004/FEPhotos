//
//  FEExtension.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import Kingfisher

extension UICollectionView {
    var fe_contentInsert : UIEdgeInsets! {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset
            } else {
                return self.contentInset
            }
        }
    }
    
    func rectForSection(section : Int) -> CGRect {
        let items = self.numberOfItems(inSection: section)
        let first = IndexPath(item: 0, section: section)
        let last = IndexPath(item: items - 1, section: section)
        let firstFrame = self.layoutAttributesForItem(at: first)?.frame ?? CGRect.zero
        let lastFrame = self.layoutAttributesForItem(at: last)?.frame ?? CGRect.zero
        let rectForSection = firstFrame.union(lastFrame)
        return rectForSection
    }
    
    //是否吸附在顶端
    func headerIsPinnedOrUnderContentInsetTop(section : Int) -> Bool{
        if let sectioheaderAttributes = self.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: 0, section: section)){
            let rectForSection = self.rectForSection(section: section)
            let isSectionScrollIntoContentInsetTop = self.contentOffset.y + self.fe_contentInsert.top <= rectForSection.maxY && self.contentOffset.y + self.fe_contentInsert.top >= rectForSection.minY - sectioheaderAttributes.frame.height
            return isSectionScrollIntoContentInsetTop
        }
        return false
    }
}
