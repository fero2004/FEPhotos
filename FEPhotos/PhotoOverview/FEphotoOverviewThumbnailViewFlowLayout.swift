//
//  FEphotoOverviewThumbnailViewFlowLayout.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/22.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

extension FEphotoOverviewThumbnailViewFlowLayout {
    static var currectKey = "FEphotoOverviewThumbnailViewFlowLayout_currectKey"
    static var currectPersentKey = "FEphotoOverviewThumbnailViewFlowLayout_currectPersentKey"
    static var nextKey = "FEphotoOverviewThumbnailViewFlowLayout_nextKey"
    static var nextPersentKey = "FEphotoOverviewThumbnailViewFlowLayout_nextPersentKey"
    var currect : FEPhotoCellData? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.currectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.currectKey) as? FEPhotoCellData
        }
    }
    var currectPersent : CGFloat? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.currectPersentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.currectPersentKey) as? CGFloat
        }
    }
    var next : FEPhotoCellData? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.nextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.nextKey) as? FEPhotoCellData
        }
    }
    var nextPersent : CGFloat? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.nextPersentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &FEphotoOverviewThumbnailViewFlowLayout.nextPersentKey) as? CGFloat
        }
    }
}

class FEphotoOverviewThumbnailViewFlowLayout: UICollectionViewFlowLayout {
    var photos : [FEPhotoCellData] = [FEPhotoCellData]()
    var normalLayout : Bool = false
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let array = super.layoutAttributesForElements(in: rect) else { return nil }
        if (normalLayout) {
            var orginReact = [CGRect]()
            var x : CGFloat = 0.0
            for _ in 0...self.photos.count - 1 {
                orginReact.append(CGRect.init(x: x, y: 0, width: self.itemSize.width, height: self.itemSize.height))
                x = x + self.itemSize.width + self.minimumInteritemSpacing
            }
            for attr in array {
                attr.frame = orginReact[attr.indexPath.row]
            }
            return array
        }
        
        if let currect = self.currect, let currectPersent = self.currectPersent, let nextPersent = self.nextPersent {
            //完全显示时候的Widths
            var pesent_1_Widths = [CGFloat]()
            var center_i = -1
            var orginReact = [CGRect]()
            var x : CGFloat = 0.0
            
            for i in 0...self.photos.count - 1 {
                let photo = photos[i]
                let fitSize = CGSize.init(width: photo.orginImage!.size.width, height: photo.orginImage!.size.height)
                let pesent_1_Width : CGFloat = itemSize.height / (fitSize.height / fitSize.width)
                //图片实际显示的宽度
                pesent_1_Widths.append(pesent_1_Width)
                //最原始的排列
                orginReact.append(CGRect.init(x: x, y: 0, width: self.itemSize.width, height: self.itemSize.height))
                x = x + self.itemSize.width + self.minimumInteritemSpacing
                
                if (photo == currect) {
                    center_i = i
                }
            }
            //当前显示的中心点x
            let currect_center_x = orginReact[center_i].midX
            //下一个显示的中心点x
            var next_center_x : CGFloat = -9999.0
            let next_i = center_i + 1
            //全部显示的宽度
            let currect_persent_1_width = pesent_1_Widths[center_i]
            //全部显示的宽度
            var next_persent_1_width : CGFloat = 0.0
            //当前实际显示的宽度
            let currect_width = (currect_persent_1_width - self.itemSize.width) * currectPersent + self.itemSize.width
            var next_width : CGFloat = 0.0
            if (next_i <= self.photos.count - 1){
                next_center_x = orginReact[next_i].midX
                next_persent_1_width = pesent_1_Widths[next_i]
                //下一个实际显示的宽度
                next_width =  (next_persent_1_width - self.itemSize.width) * nextPersent + self.itemSize.width
            }
            /*
             将正在做动画的两个图片作为一个整体
             1.算出当前显示图片最大时候的宽度,rect,位置
             2.算出下一个要显示的图片最大时候的宽度,rect,位置
             3.根据比例计算出最大和最小之间实际显示的矩形的位置
             4.将做动画的图片放入这个矩形中
             */
            //当前显示图片最大时候的宽度
            let currect_persent_1_hole_width = currect_persent_1_width + self.minimumLineSpacing + self.itemSize.width
            //当前显示图片最大时候的rect
            let currect_persent_1_hole_react = CGRect.init(x: currect_center_x - currect_persent_1_width/2,
                                                           y: 0,
                                                           width: currect_persent_1_hole_width,
                                                           height: self.itemSize.height)
            //如果没有next_center_x表示是最后一张
            if (next_center_x == -9999.0)
            {
                //从minx往前排
                let minx = currect_persent_1_hole_react.minX
                
                for attr in array {
                    if (attr.indexPath.row == center_i) {
                        center_i = array.firstIndex(of: attr) ?? 0
                        break
                    }
                }
                
                if (center_i < array.count) {
                    let left = array[0...center_i]
                    var i = left.count - 1
                    var orgin_x : CGFloat = minx
                    while i >= 0 {
                        let attr = left[i]
                        if (i == left.count - 1) {
                            //rect内部
                            attr.frame = CGRect.init(x: minx,
                                                     y: 0,
                                                     width: currect_width,
                                                     height: self.itemSize.height)
                        } else {
                            attr.frame = CGRect.init(x: orgin_x - self.itemSize.width,
                                                     y: 0,
                                                     width: self.itemSize.width,
                                                     height: self.itemSize.height)
                        }
                        orgin_x = attr.frame.minX - self.minimumLineSpacing
                        i = i - 1
                    }
                }
            }
            else if (next_center_x != -9999.0) {
                //下一个要显示的图片最大时候的宽度
                let next_persent_1_hole_width = next_persent_1_width + self.minimumLineSpacing + self.itemSize.width
                //下一个要显示的图片最大时候的rect
                let next_persent_1_hole_react = CGRect.init(x: next_center_x + next_persent_1_width / 2 - next_persent_1_hole_width,
                                                            y: 0,
                                                            width: next_persent_1_hole_width,
                                                            height: self.itemSize.height)
                
                let currect_1_center_x = currect_persent_1_hole_react.midX
                let currect_0_center_x = next_persent_1_hole_react.midX
                //根据比例计算出实际要显示的中心点
                let center_x = currect_0_center_x + abs(currect_1_center_x - currect_0_center_x) * currectPersent
                //实际要显示的宽度
                let width = currect_width + next_width + self.minimumLineSpacing
                //实际显示的矩型位置
                let rect = CGRect.init(x: center_x - width/2,
                                       y: 0,
                                       width: width,
                                       height: self.itemSize.height)
                //从minx往前排
                let minx = rect.minX
                //从max往后排,rect内部就是显示的两张图片
                let maxx = rect.maxX
                
                for attr in array {
                    if (attr.indexPath.row == center_i) {
                        center_i = array.firstIndex(of: attr) ?? 0
                        break
                    }
                }
                
                if (center_i < array.count) {
                    let left = array[0...center_i]
                    var i = left.count - 1
                    var orgin_x : CGFloat = minx
                    while i >= 0 {
                        let attr = left[i]
                        if (i == left.count - 1) {
                            //rect内部
                            attr.frame = CGRect.init(x: minx,
                                                     y: 0,
                                                     width: currect_width,
                                                     height: self.itemSize.height)
                        } else {
                            attr.frame = CGRect.init(x: orgin_x - self.itemSize.width,
                                                     y: 0,
                                                     width: self.itemSize.width,
                                                     height: self.itemSize.height)
                        }
                        orgin_x = attr.frame.minX - self.minimumLineSpacing
                        i = i - 1
                    }
                }
                let next_start_i = center_i + 1
                if (next_start_i <= array.count-1) {
                    let right = array[next_start_i...array.count-1]
                    var i = next_start_i
                    var orgin_x : CGFloat = maxx
                    while i <= array.count - 1 {
                        let attr = right[i]
                        if (i == next_start_i) {
                            //rect内部
                            attr.frame = CGRect.init(x: maxx - next_width,
                                                     y: 0,
                                                     width: next_width,
                                                     height: self.itemSize.height)
                        } else {
                            attr.frame = CGRect.init(x: orgin_x,
                                                     y: 0,
                                                     width: self.itemSize.width,
                                                     height: self.itemSize.height)
                        }
                        orgin_x = attr.frame.maxX + self.minimumLineSpacing
                        i = i + 1
                    }
                }
            }
        }
        return array
    }
    
    override func prepare() {
        super.prepare()
        self.minimumInteritemSpacing = 2.0
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var rect = CGRect.zero
        rect.origin.x = proposedContentOffset.x
        rect.origin.y = 0.0
        rect.size = self.collectionView!.frame.size
       
        guard let array = self.layoutAttributesForElements(in: rect) else { return proposedContentOffset }
        let centerx = proposedContentOffset.x + self.collectionView!.frame.size.width / 2
        
        var minDelta = CGFloat.greatestFiniteMagnitude
        for attr in array {
            if(abs(minDelta) > abs(attr.center.x - centerx)) {
                minDelta = attr.center.x - centerx
            }
        }
        let x = proposedContentOffset.x + minDelta
        return CGPoint.init(x: x, y: proposedContentOffset.y)
    }
}
