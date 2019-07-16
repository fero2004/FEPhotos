//
//  FEPhotoCollectionViewAnimator.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/19.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

enum FEPhotoAnimatorRowType {
    //adjoinSection 紧靠sectionheader的第一行row
    case adjoinSection,normal
}

enum FEPhotoAnimatorRowItemType {
    //from只表示fromviewcontroller的item
    //fromAndTo 表示fromviewcontroller和toviewcontroller都存在的item
    case from,fromAndTo
}

class FEPhotoAnimatorRowDetailItem : NSObject {
    var indexPath : IndexPath?
    // 虚拟item
    var isInvented : Bool = false
    var sectionData : FEPhotoSectionData?
    var photoData : FEPhotoCellData?
}

class FEPhotoAnimatorRowItem : NSObject {
    var type : FEPhotoAnimatorRowItemType = .from
    var from = FEPhotoAnimatorRowDetailItem()
    var to = FEPhotoAnimatorRowDetailItem()
    //临时存一下结束的位置,主要用在返回动画上
    var rect : CGRect = CGRect.zero
}

class FEPhotoAnimatorRow : NSObject {
    var type : FEPhotoAnimatorRowType = .normal
    var items = [FEPhotoAnimatorRowItem]()
}

class FEPhotoCollectionViewAnimator: NSObject,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    var animationDuration: Double! = 0.5
    var operation : UINavigationController.Operation = UINavigationController.Operation.push
    
    init(operation : UINavigationController.Operation!) {
        super.init()
        self.operation = operation
    }
    
    //MARK :- UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func buildRows(viewController : FEPhotoBaseCollectionController!, fill : Bool! = false) -> [FEPhotoAnimatorRow]? {
        if let indexPathsForVisibleCells = viewController.collectionView?.indexPathsForVisibleItems,
            let indexPathsForVisibleSupplementaryElements = viewController.collectionView?.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader) {
            //排序
            let indexPaths = indexPathsForVisibleCells.sorted(by: { (a,b) -> Bool in
                return a.compare(b) == .orderedAscending
            })
            var rows = [FEPhotoAnimatorRow]()
            let row = FEPhotoAnimatorRow()
            rows.append(row)
            //一行的个数
            let numberInRow = viewController.controllerType.itemCount()
            let datas = viewController.datas
            
            for i in 0...indexPaths.count - 1 {
                let indexPath = indexPaths[i]
                let row = rows.last!
                // 第一行的为adjoinSection
                if (indexPath.row >= 0 && indexPath.row < numberInRow) {
                    row.type = .adjoinSection
                } else {
                    row.type = .normal
                }
                if ((indexPath.row + 1) % numberInRow == 0 && indexPath.row != 0) {
                    let rowItem = FEPhotoAnimatorRowItem()
                    rowItem.from.indexPath = indexPath
                    rowItem.from.sectionData = datas[indexPath.section]
                    rowItem.from.photoData = datas[indexPath.section].photos[indexPath.row]
                    row.items.append(rowItem)
                    if (i + 1 <= indexPaths.count - 1) {
                        rows.append(FEPhotoAnimatorRow())
                    }
                } else {
                    let rowItem = FEPhotoAnimatorRowItem()
                    rowItem.from.indexPath = indexPath
                    rowItem.from.sectionData = datas[indexPath.section]
                    rowItem.from.photoData = datas[indexPath.section].photos[indexPath.row]
                    row.items.append(rowItem)
                    if (i + 1 <= indexPaths.count - 1) {
                        let nextIndexPath = indexPaths[i + 1]
                        if (nextIndexPath.section != indexPath.section) {
                            rows.append(FEPhotoAnimatorRow())
                        }
                    }
                }
            }
            if (fill) {
                //将格子填满一行
                for row in rows {
                    if (row.items.count < numberInRow) {
                        if let indexPath = row.items.last?.from.indexPath {
                            var indexPathRow = indexPath.row
                            for _ in 0...(numberInRow - row.items.count - 1) {
                                indexPathRow = indexPathRow + 1
                                let rowItem = FEPhotoAnimatorRowItem()
                                rowItem.from.indexPath = IndexPath.init(row: indexPathRow, section: indexPath.section)
                                rowItem.from.sectionData = datas[indexPath.section]
                                rowItem.from.isInvented = true
                                row.items.append(rowItem)
                            }
                        }
                    }
                }
            }
            return rows
        }
        return nil
    }
    
    //合并rows
    func mergeToRowsToFromRows(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) -> (Int,Int,Int) {
        if let fromRows = fromRows, let toRows = toRows {
            //找到选择的item在哪一行
            var fromRowIndex = 0
            //开始的item
            var startIndex = 0
            for i in 0...fromRows.count - 1 {
                let row = fromRows[i]
                for j in 0...row.items.count - 1 {
                    let item = row.items[j]
                    if (item.from.photoData == fromViewController.selectedPhoto) {
                        fromRowIndex = i
                        startIndex = j
                    }
                }
            }
            var toRowIndex = 0
            //同一行有多个item的时候,最开始的item是第一个
            var offset = 0
            for i in 0...toRows.count - 1 {
                let row = toRows[i]
                for j in 0...row.items.count - 1 {
                    let item = row.items[j]
                    if (item.from.photoData == toViewController.selectedPhoto) {
                        toRowIndex = i
                        offset = j
                    }
                }
            }
           
            //移动到最开始的item
            startIndex = startIndex - offset
            if (startIndex <= 0 ){
                startIndex = 0
            }
            var startToRowIndex = toRowIndex
            var startFromRowIndex = fromRowIndex
            while (startToRowIndex >= 0 && startFromRowIndex >= 0) {
                let toRow = toRows[startToRowIndex]
                let fromRow = fromRows[startFromRowIndex]
                var tempStartIndex = startIndex
                var isFound = false
                for item in toRow.items {
                    // 这里超过了需要弄一个虚拟的iterm加到fromRow.items上？
                    if (tempStartIndex < fromRow.items.count) {
                        let startItem = fromRow.items[tempStartIndex]
                        //如果在这个section里
                        if (startItem.from.sectionData!.isPhotoInphotos(photo: item.from.photoData)) {
                            //合并
                            startItem.to = item.from
                            startItem.type = .fromAndTo
                            
                            item.to = startItem.from
                            item.type = .fromAndTo
                            isFound = true
                        }
                    }
                    tempStartIndex = tempStartIndex + 1
                }
                //如果某一行没有找到在section里的就直接跳过,从这一行开始分割
                if (!isFound) {
                    break;
                }
                startToRowIndex = startToRowIndex - 1
                startFromRowIndex = startFromRowIndex - 1
            }
            startToRowIndex = toRowIndex + 1
            startFromRowIndex = fromRowIndex + 1
            while (startToRowIndex <= toRows.count - 1 && startFromRowIndex <= fromRows.count - 1) {
                let toRow = toRows[startToRowIndex]
                let fromRow = fromRows[startFromRowIndex]
                var tempStartIndex = startIndex
                var isFound = false
                for item in toRow.items {
                    if (tempStartIndex < fromRow.items.count) {
                        let startItem = fromRow.items[tempStartIndex]
                        //如果在这个section里
                        if (startItem.from.sectionData!.isPhotoInphotos(photo: item.from.photoData)) {
                            //合并
                            startItem.to = item.from
                            startItem.type = .fromAndTo
                            
                            item.to = startItem.from
                            item.type = .fromAndTo
                            isFound = true
                        }
                    }
                    tempStartIndex = tempStartIndex + 1
                }
                //如果某一行没有找到在section里的就直接跳过,从这一行开始分割
                if (!isFound) {
                    break;
                }
                startToRowIndex = startToRowIndex + 1
                startFromRowIndex = startFromRowIndex + 1
            }
            return (fromRowIndex,toRowIndex,startIndex)
        }
        return (-1,-1,-1)
    }
    
    //sectionheader跟着第一行的row变化的
    func doPushAnimateInfromViewControllerWithSection(row: FEPhotoAnimatorRow!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,
                                                      toRect:[Int:CGRect]!) {
        let rect = toRect[0]!
        let item = row.items.first!
        var frame = CGRect.zero
        if(row.type == .adjoinSection && item.type == .fromAndTo) {
            if let toSectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.to.indexPath!) {
                
                frame = CGRect.init(x: 0,
                                    y: rect.minY - toSectionheader.height,
                                    width: toSectionheader.width,
                                    height: toSectionheader.height)
                let centery = frame.midY + fromViewController.collectionView.contentOffset.y + fromViewController.collectionView.fe_contentInsert.top
                frame = CGRect.init(x: frame.origin.x,
                                    y: centery - frame.height/2,
                                    width: frame.width,
                                    height: frame.height)
            }
        } else if(row.type == .adjoinSection) {
            if let fromSectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!) {
                
                frame = CGRect.init(x: 0,
                                    y: rect.minY - fromSectionheader.height,
                                    width: fromSectionheader.width,
                                    height: fromSectionheader.height)
                let centery = frame.midY + fromViewController.collectionView.contentOffset.y + fromViewController.collectionView.fe_contentInsert.top
                frame = CGRect.init(x: frame.origin.x,
                                    y: centery - frame.height/2,
                                    width: frame.width,
                                    height: frame.height)
            }
        }
        if let fromSectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!) {
            if(!frame.isEmpty) {
                // 判断是否吸附在顶部
//                let rect = fromSectionheader.convert(fromSectionheader.bounds, to: UIApplication.shared.keyWindow)
//                let temprect = CGRect.init(x: 0,
//                                           y: fromViewController.collectionView.fe_contentInsert.top - fromSectionheader.frame.height,
//                                           width: fromSectionheader.frame.width,
//                                           height: fromSectionheader.frame.height)

                UIView.animate(withDuration: self.animationDuration,
                               delay: 0,
                               usingSpringWithDamping: 0.75,
                               initialSpringVelocity: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: { () -> Void in
                                if (fromViewController.collectionView.headerIsPinnedOrUnderContentInsetTop(section: item.from.indexPath!.section)) {
                                    fromSectionheader.alpha = 1
                                }
                                else {
                                    fromSectionheader.alpha = 0
                                }
                                fromSectionheader.frame = frame
                },
                               completion: { (b) in
                })
            }
        }
    }
    
    func doPushRowAnimate(row: FEPhotoAnimatorRow!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,
        toRect:[Int:CGRect]!){
        var startIndex = -1
        let count = toViewController.controllerType.itemCount()
        for i in 0...row.items.count - 1 {
            let item = row.items[i]
            if (item.from.isInvented) {
                continue
            }
            if(item.type == .fromAndTo && startIndex == -1) {
                startIndex = i
            }
            if let fromIndexPath = item.from.indexPath {
                // fromIndexPath可能是虚拟的,这里要判断下
                if let fromItem = fromViewController.collectionView.cellForItem(at: fromIndexPath) as? FEPhotoCell{
                    let saveSize = fromItem.frame.size
                    // torect是屏幕的位置,需要转到collection的cotentsize上
                    var frame = toRect[i]!
                    let centery = frame.midY + fromViewController.collectionView.contentOffset.y + fromViewController.collectionView.fe_contentInsert.top
                    frame = CGRect.init(x: frame.origin.x,
                                        y: centery - frame.height/2,
                                        width: frame.width,
                                        height: frame.height)
                    var toImageView : UIImageView?
                    // 防止动画切换太生硬,这里加一个toitem的imageview,做一个切换的动画
                    if(item.type == .fromAndTo) {
                        toImageView = UIImageView.init(image: item.to.photoData!.smallImage)
                        toImageView?.frame = CGRect.init(x: 0, y: 0, width: saveSize.width, height: saveSize.height)
                        toImageView?.alpha = 1
                        toImageView?.clipsToBounds = true
                        toImageView?.contentMode = .scaleAspectFill
                        fromItem.contentView.insertSubview(toImageView!, at: 0)
                    }
                    UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: 0.75,
                                   initialSpringVelocity: 0,
                                   options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                   animations: { () -> Void in
                                    
                                    fromItem.frame = frame
                                    fromItem.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
                                    
                                    fromItem.imageView.alpha = (toImageView != nil) ? 0 : 1
                                    
                                    toImageView?.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
                    },
                                   completion: { (b) in
                                    toImageView?.removeFromSuperview()
                                    fromItem.imageView.alpha = 1
                    })
                    // 从开始的位置到下一屏的数量的alpha为0,其他的alpha不变
                    if (startIndex >= 0 && i - startIndex < count && item.type == .from) {
                        UIView.animate(withDuration: self.animationDuration / 2,
                                       delay: 0,
                                       animations: { () -> Void in
                                        fromItem.alpha = 0
                        },
                                       completion: { (b) in
                        })
                    }
                }
            }
        }
        self.doPushAnimateInfromViewControllerWithSection(row: row, fromViewController: fromViewController, toViewController:toViewController, toRect: toRect)
    }
    
    func doPushAnimateInfromViewControllerWithRow(row: FEPhotoAnimatorRow!,startItem: FEPhotoAnimatorRowItem!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!, compute : Bool = false) -> CGFloat {
        var startx : CGFloat = MAXFLOAT.cgFloat
        var toRect = [-9999:CGRect.zero]
        if let toIndexPath = startItem.to.indexPath{
            let toCell = toViewController.collectionView.cellForItem(at: toIndexPath)
            let toSize = toCell!.frame.size
            let index = row.items.firstIndex(of: startItem)!
            
            let rect = toCell!.convert(toCell!.bounds, to: UIApplication.shared.keyWindow)
            //相对于屏幕的中心位置
            let toCenter = CGPoint.init(x: rect.midX, y: rect.midY - toViewController.collectionView.fe_contentInsert.top)
            var x = toCenter.x - toSize.width * CGFloat(index)
            startx = x
            toRect = [index:CGRect.init(x: toCenter.x - toSize.width/2,
                                            y: toCenter.y - toSize.height/2,
                                            width: toSize.width,
                                            height: toSize.height)]
            var i = 0
            while (i < row.items.count) {
                toRect[i] = CGRect.init(x: x - toSize.width/2,
                                        y: toCenter.y - toSize.height/2,
                                        width: toSize.width,
                                        height: toSize.height)
                let item = row.items[i]
                // 其实可以不用toRect,直接用item.rect,遗留代码,后续优化 TODO
                item.rect = toRect[i]!
                i = i + 1
                x = x + toSize.width
            }
            if (!compute) {
                self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
            }
        }
        return startx
    }
    
    // compute是否只是用做计算结束坐标,如果是计算的话,就不做动画.主要用在返回动画,返回动画,只算出结束坐标
    func doPushAnimateInfromViewController(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,fromRowIndex : Int!, compute : Bool = false) {
        var startIndex = 0
        var centerx : CGFloat = 0.0
//        var toRowsRect: [Int:[Int:CGRect]] = [-9999:[-9999:CGRect.zero]]
        if let fromRows = fromRows, let toRows = toRows{
            //从点击的行分开向上
            var startRows = [FEPhotoAnimatorRow]()
            //从点击的行分开向下
            var endRows = [FEPhotoAnimatorRow]()
            if (fromRowIndex >= 0) {
                for i in 0...fromRows.count - 1 {
                    let row = fromRows[i]
                    var find = false
                    for item in row.items {
                        if (item.type == .fromAndTo) {
                            startIndex = row.items.firstIndex(of: item) ?? -1
                            find = true
                            //一行做动画
                            let value = self.doPushAnimateInfromViewControllerWithRow(row: row, startItem: item, fromViewController: fromViewController,toViewController: toViewController,compute: compute)
                            centerx = value
//                            let temprect = value.1
//                            toRowsRect[i] = temprect
                            break
                        }
                    }
                    //单独做动画
                    if (!find) {
                        if (i < fromRowIndex) {
                            startRows.append(row)
                        } else {
                            endRows.append(row)
                        }
                    }
                }
            }

            //找到第一个元素,//找到最后一个元素
            if let tofirstItem = toRows.first?.items.first?.from, let tolastItem = toRows.last?.items.last?.from, let toFirstRow = toRows.first, let toLastRow  = toRows.last{
                
                var startFrame = CGRect.zero
                //如果第一个元素是section,startRows整体移动到section上面
                if(toFirstRow.type == .adjoinSection) {
                    if let sectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: tofirstItem.indexPath!) {
                        let rect = sectionheader.convert(sectionheader.bounds, to: UIApplication.shared.keyWindow)
                        startFrame = rect
                        // 要减去startFrame.height,因为是悬浮的
                        startFrame.origin.y = startFrame.origin.y - toViewController.collectionView.fe_contentInsert.top - startFrame.height
                    }
                }
                else
                {
                    if let cell = toViewController.collectionView.cellForItem(at: tofirstItem.indexPath!) {
                        let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                        startFrame = rect
                        startFrame.origin.y = startFrame.origin.y - toViewController.collectionView.fe_contentInsert.top
                    }
                }
                var endFrame = CGRect.zero
                if let cell = toViewController.collectionView.cellForItem(at: tolastItem.indexPath!) {
                    let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                    endFrame = rect
                    endFrame.origin.y = endFrame.origin.y - toViewController.collectionView.fe_contentInsert.top
                }
                if (startIndex >= 0) {
                    let toLayout = toViewController.collectionViewLayout as! UICollectionViewFlowLayout
                    let toSize = toLayout.itemSize
                    
                    var i = startRows.count - 1
                    //最上面的center
                    var centery = startFrame.maxY - toSize.height/2
                    while i >= 0 {
                        let row = startRows[i]
                        var j = 0
                        var x = centerx
                        var toRect = [-9999 : CGRect.zero]
                        while (j < row.items.count) {
                            toRect[j] = CGRect.init(x: x - toSize.width/2,
                                                    y: centery - toSize.height/2,
                                                    width: toSize.width,
                                                    height: toSize.height)
                            let item = row.items[j]
                            // 其实可以不用toRect,直接用item.rect,遗留代码,后续优化 TODO
                            item.rect = toRect[j]!
                            j = j + 1
                            x = x + toSize.width
                        }
//                        let index = fromRows.firstIndex(of: row)!
//                        toRowsRect[index] = toRect
                        if (!compute) {
                            self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
                        }
                        //如果第一个是sectionheader减去sectionheader的高度
                        if (row.type == .adjoinSection){
                            if let sectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: row.items.first!.from.indexPath!) {
                                let rect = sectionheader.convert(sectionheader.bounds, to: UIApplication.shared.keyWindow)
                                centery = centery - toSize.height/2 - rect.height - toSize.height/2
                            }
                        } else {
                            centery = centery - toSize.height
                        }
                        i = i - 1
                    }
                    //最下面的center
                    i = 0
                    centery = endFrame.maxY
                    if (endRows.count > 0) {
                        let row = endRows[0]
                        if (row.type == .adjoinSection){
                            if let sectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: row.items.first!.from.indexPath!) {
                                let rect = sectionheader.convert(sectionheader.bounds, to: UIApplication.shared.keyWindow)
                                centery = centery + rect.height
                            }
                        }
                    }
                    centery = centery + toSize.height/2
                    while i <= endRows.count - 1 {
                        let row = endRows[i]
                        var j = 0
                        var x = centerx
                        var toRect = [-9999 : CGRect.zero]
                        while (j < row.items.count) {
                            toRect[j] = CGRect.init(x: x - toSize.width/2,
                                                    y: centery - toSize.height/2,
                                                    width: toSize.width,
                                                    height: toSize.height)
                            let item = row.items[j]
                            // 其实可以不用toRect,直接用item.rect,遗留代码,后续优化 TODO
                            item.rect = toRect[j]!
                            j = j + 1
                            x = x + toSize.width
                        }
//                        let index = fromRows.firstIndex(of: row)!
//                        toRowsRect[index] = toRect
                        if (!compute) {
                             self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
                        }
                        i = i + 1
                        if (i < endRows.count) {
                            let temprow = endRows[i]
                            if (temprow.type == .adjoinSection){
                                if let sectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: temprow.items.first!.from.indexPath!) {
                                    let rect = sectionheader.convert(sectionheader.bounds, to: UIApplication.shared.keyWindow)
                                    centery = centery + toSize.height/2 + rect.height + toSize.height/2
                                }
                            } else {
                                centery = centery + toSize.height
                            }
                        }
                    }
                }
            }
        }
    }
    
    func doPushAnimateInToViewController(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,fromRowIndex : Int!, toRowIndex : Int!, startIndex: Int!, compute : Bool = false) {
        if let fromRows = fromRows, let toRows = toRows{
            if(fromRowIndex >= 0 && toRowIndex >= 0 && startIndex >= 0) {
                let fromLayout = fromViewController.collectionViewLayout as! UICollectionViewFlowLayout
                let fromSize = fromLayout.itemSize
                var i: Int = toRowIndex
                var j : Int = fromRowIndex
                let startItem = fromRows[fromRowIndex].items.first!
                var centery : CGFloat = 0.0
                var centerx : CGFloat = 0.0
                if let cell = fromViewController.collectionView.cellForItem(at: startItem.from.indexPath!) {
                    let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                    centery = rect.midY
                    centerx = rect.midX
                }
                var tempCetnery = centery
                var heads = [IndexPath]()
                while i >= 0 {
                    let toRow = toRows[i]
                    var orginx = CGFloat(startIndex) * fromSize.width
                    for k in 0...toRow.items.count - 1 {
                        var frame = CGRect.init(x: orginx,
                                                y: tempCetnery - fromSize.height / 2,
                                                width: fromSize.width,
                                                height: fromSize.height)
                        let item = toRow.items[k]
                        item.rect = frame
                        if (!compute) {
                            if let cell = toViewController.collectionView.cellForItem(at: item.from.indexPath!) as? FEPhotoCell{
                                let sectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!)
                                let saveFrame = cell.frame
                                let realy = tempCetnery + toViewController.collectionView.contentOffset.y
                                frame = CGRect.init(x: frame.origin.x,
                                                    y: realy - frame.height/2,
                                                    width: frame.width,
                                                    height: frame.height)
                                cell.frame = frame
                                cell.alpha = 0
                                cell.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
//                                sectionheader?.alpha = 0
                                if(sectionheader != nil) {
                                    heads.append(item.from.indexPath!)
                                }
                                UIView.animate(withDuration: self.animationDuration,
                                               delay: 0,
                                               usingSpringWithDamping: 0.75,
                                               initialSpringVelocity: 0,
                                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                               animations: { () -> Void in
                                                cell.alpha = 1
                                                cell.frame = saveFrame
                                                cell.imageView.frame = CGRect.init(x: 0, y: 0, width: saveFrame.width, height: saveFrame.height)
                                },
                                               completion: { (b) in
                                })
                            }
                        }
                        orginx = orginx + fromSize.width
                    }
                    j = j - 1
                    var fromRow : FEPhotoAnimatorRow?
                    if (j >= 0) {
                        fromRow = fromRows[j]
                    }
                    let fromRowItem = fromRow?.items.first
                    if(fromRowItem != nil && fromRowItem?.type == .fromAndTo) {
                        if let cell = fromViewController.collectionView.cellForItem(at: fromRowItem!.from.indexPath!) {
                            let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                            tempCetnery = rect.midY
                        }
                    } else {
                        tempCetnery = tempCetnery - fromSize.height
                    }
                    i = i - 1
                }
                
                tempCetnery = centery
                i = toRowIndex + 1
                j  = fromRowIndex + 1
                var fromRow : FEPhotoAnimatorRow?
                if (j < fromRows.count) {
                    fromRow = fromRows[j]
                }
                let fromRowItem = fromRow?.items.first
                if(fromRowItem != nil && fromRowItem?.type == .fromAndTo) {
                    if let cell = fromViewController.collectionView.cellForItem(at: fromRowItem!.from.indexPath!) {
                        let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                        tempCetnery = rect.midY
                    }
                } else {
                    tempCetnery = tempCetnery + fromSize.height
                }
                while i < toRows.count {
                    let toRow = toRows[i]
                    var orginx = CGFloat(startIndex) * fromSize.width
                    for k in 0...toRow.items.count - 1 {
                        var frame = CGRect.init(x: orginx,
                                                y: tempCetnery - fromSize.height / 2,
                                                width: fromSize.width,
                                                height: fromSize.height)
                        let item = toRow.items[k]
                        item.rect = frame
                        if (!compute) {
                            if let cell = toViewController.collectionView.cellForItem(at: item.from.indexPath!) as? FEPhotoCell {
                                let sectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!)
                                let saveFrame = cell.frame
                                let realy = tempCetnery + toViewController.collectionView.contentOffset.y
                                frame = CGRect.init(x: frame.origin.x,
                                                    y: realy - frame.height/2,
                                                    width: frame.width,
                                                    height: frame.height)
                                cell.frame = frame
                                cell.alpha = 0
                                cell.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
//                                sectionheader?.alpha = 0
                                if(sectionheader != nil) {
                                    heads.append(item.from.indexPath!)
                                }
                                UIView.animate(withDuration: self.animationDuration,
                                               delay: 0,
                                               usingSpringWithDamping: 0.75,
                                               initialSpringVelocity: 0,
                                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                               animations: { () -> Void in
                                                cell.alpha = 1
                                                cell.frame = saveFrame
                                                cell.imageView.frame = CGRect.init(x: 0, y: 0, width: saveFrame.width, height: saveFrame.height)
                                                //                                            sectionheader?.alpha = 1
                                },
                                               completion: { (b) in
                                                
                                })
                            }
                        }
                        orginx = orginx + fromSize.width
                    }
                    j = j + 1
                    var fromRow : FEPhotoAnimatorRow?
                    if (j < fromRows.count) {
                        fromRow = fromRows[j]
                    }
                    let fromRowItem = fromRow?.items.first
                    if(fromRowItem != nil && fromRowItem?.type == .fromAndTo) {
                        if let cell = fromViewController.collectionView.cellForItem(at: fromRowItem!.from.indexPath!) {
                            let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                            tempCetnery = rect.midY
                        }
                    } else {
                        tempCetnery = tempCetnery + fromSize.height
                    }
                    i = i + 1
                }
                if (!compute) {
                    //delay为了防止立即显示,会挡住cell的显示
                    for indexPath in heads {
                        // 判断是否吸附在顶部
//                        let rect = h.convert(h.bounds, to: UIApplication.shared.keyWindow)
//                        let temprect = CGRect.init(x: 0,
//                                                   y: toViewController.collectionView.fe_contentInsert.top - h.frame.height,
//                                                   width: h.frame.width,
//                                                   height: h.frame.height)
                        if let header = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                        {
                            if (toViewController.collectionView.headerIsPinnedOrUnderContentInsetTop(section: indexPath.section)) {
                                header.alpha = 1
                            } else {
                                header.alpha = 0
                            }
                            UIView.animate(withDuration: self.animationDuration,
                                           delay: self.animationDuration / 4,
                                           animations: { () -> Void in
                                            header.alpha = 1
                            },
                                           completion: { (b) in
                                            
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    func pushAnimateInfromViewController(transitionContext: UIViewControllerContextTransitioning!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) {
        
        let fromRows = self.buildRows(viewController: fromViewController, fill: true)
        
        toViewController.view.alpha = 0
        toViewController.view.isHidden = true
        
        toViewController.collectionView.setNeedsLayout()
        toViewController.collectionView.layoutIfNeeded()
        // scroollToSelectedPhotoInDatas必须在DispatchQueue.main.async执行,要不contentoffset不准确
        DispatchQueue.main.async {
            toViewController.scroollToSelectedPhotoInDatas(pre: fromViewController)
            //必须reloaddata,cell的位置才准确
            toViewController.collectionView.reloadData{
                let toRows = self.buildRows(viewController: toViewController)
                let (fromRowIndex,toRowIndex,startIndex) =  self.mergeToRowsToFromRows(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController)
                //这里要先做to的动画,如果先做from的动画,from的cell frame变化了会影响to的cell位置
                self.doPushAnimateInToViewController(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController,fromRowIndex: fromRowIndex,toRowIndex: toRowIndex,startIndex: startIndex)
                // from动画
                self.doPushAnimateInfromViewController(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController,fromRowIndex: fromRowIndex)
                
                UIView.animate(withDuration: self.animationDuration,
                               animations: {
                                toViewController.view.alpha = 1
                                toViewController.view.isHidden = false
                }) { (b) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                //fromViewController.collectionView.reloadData必须在transitionContext.completeTransition后执行
                    //而且必须在UIView.animate里reload,要不第一个sectionheader位置还是做动画之后的动画
                    fromViewController.collectionView.reloadData(){}
                }
            }
        }
    }
    
    func pushAnimate(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! FEPhotoBaseCollectionController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! FEPhotoBaseCollectionController
        let container = transitionContext.containerView
        container.backgroundColor = UIColor.clear
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        container.insertSubview(toViewController.view, aboveSubview: fromViewController.view)

        self.pushAnimateInfromViewController(transitionContext: transitionContext, fromViewController: fromViewController, toViewController: toViewController)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if (self.operation == .push) {
            self.pushAnimate(using: transitionContext)
        } else if(self.operation == .pop) {
            self.popAnimate(using: transitionContext)
        }
    }
}

extension FEPhotoCollectionViewAnimator {
    
    func doPopAnimateInToViewController(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,toRowIndex : Int!) {
        if let toRows = toRows, let fromRows = fromRows {
            var heads = [(IndexPath , FEPhotoAnimatorRowType,CGRect)]()//[UICollectionReusableView]()
            //开始做动画的位置
            self.doPushAnimateInfromViewController(fromRows: toRows, toRows: fromRows,fromViewController: toViewController,toViewController: fromViewController,fromRowIndex: toRowIndex,compute: true)
            for row in toRows {
                for item in row.items {
                    if (item.from.isInvented) {
                        continue
                    }
                    if let cell = toViewController.collectionView.cellForItem(at: item.from.indexPath!) as? FEPhotoCell{
                        let saveFrame = cell.frame
                        var frame = item.rect
                        let centery = frame.midY + toViewController.collectionView.contentOffset.y + toViewController.collectionView.fe_contentInsert.top
                        frame = CGRect.init(x: frame.origin.x,
                                            y: centery - frame.height/2,
                                            width: frame.width,
                                            height: frame.height)
                        cell.frame = frame
                        cell.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
                        let sectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!)
                        if (sectionheader != nil) {
                            heads.append((item.from.indexPath! , row.type, frame))
                        }
                        UIView.animate(withDuration: self.animationDuration / 2,
                                       delay: 0,
//                                       usingSpringWithDamping: 0.75,
//                                       initialSpringVelocity: 0,
                                       options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                       animations: { () -> Void in
                                        cell.alpha = 1
                                        cell.frame = saveFrame
                                        cell.imageView.frame = CGRect.init(x: 0, y: 0, width: saveFrame.width, height: saveFrame.height)
                                        //                                            sectionheader?.alpha = 1
                        },
                                       completion: { (b) in
                                        
                        })
                    }
                }
            }
            for (indexPath, type, cellFrame) in heads {
                let h = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath)!
                let saveFrame = h.frame
                if (type == .adjoinSection) {
                    h.frame = CGRect.init(x: 0,
                                          y: cellFrame.minY - h.frame.height,
                                          width: h.frame.width,
                                          height: h.frame.height)
                    UIView.animate(withDuration: self.animationDuration / 2,
                                   delay: 0,
                                   animations: { () -> Void in
                                    h.frame = saveFrame
                    },
                                   completion: { (b) in
                                    
                    })
                }
            }
        }
    }
    
    //这里可以优化,动画应该在from上面做一个两个image渐变的效果,现在效果勉强可以 todo
    func doPopAnimateInFromViewController(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,fromRowIndex : Int!, toRowIndex : Int!, startIndex: Int!) {
        if let toRows = toRows, let fromRows = fromRows {
            self.doPushAnimateInToViewController(fromRows: toRows, toRows: fromRows, fromViewController: toViewController, toViewController: fromViewController, fromRowIndex: toRowIndex, toRowIndex: fromRowIndex, startIndex: startIndex, compute: true)
            for row in fromRows {
                for item in row.items {
                    if (item.from.isInvented) {
                        continue
                    }
                    if let cell = fromViewController.collectionView.cellForItem(at: item.from.indexPath!) as? FEPhotoCell{
                        var frame = item.rect
                        let centery = frame.midY + fromViewController.collectionView.contentOffset.y
                        frame = CGRect.init(x: frame.origin.x,
                                            y: centery - frame.height/2,
                                            width: frame.width,
                                            height: frame.height)
                        var sectionFrame = CGRect.zero
                        let sectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!)
                        sectionFrame = sectionheader?.frame ?? CGRect.zero
                        sectionFrame = CGRect.init(x: sectionFrame.origin.x,
                                                   y: sectionFrame.origin.y,
                                                   width: sectionFrame.width,
                                                   height: 0)
                        if (item.type == .fromAndTo) {
//                            cell.alpha = 0
                            if let toSectionheader = toViewController.collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: item.to.indexPath!) {
                                sectionFrame = CGRect.init(x: 0,
                                                           y: frame.minY - toSectionheader.frame.height,
                                                           width: toSectionheader.frame.width,
                                                           height: toSectionheader.frame.height)
                            }
                        } else {
                            _ = sectionheader?.subviews.map({ (view) in
                                view.isHidden = true
                            })
                        }
                       
                        UIView.animate(withDuration: self.animationDuration / 2,
                                       delay: 0,
                                       //                                       usingSpringWithDamping: 0.75,
                            //                                       initialSpringVelocity: 0,
                                                                  options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                            animations: { () -> Void in
                                sectionheader?.frame = sectionFrame
                                sectionheader?.alpha = 0
                                cell.alpha = 0
                                cell.frame = frame
                                cell.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
                                //                                            sectionheader?.alpha = 1
                        },
                            completion: { (b) in

                        })
                    }
                }
            }
        }
    }
    
    func mergeFromRowsToToRows(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) -> (Int,Int,Int) {
        return self.mergeToRowsToFromRows(fromRows: toRows, toRows: fromRows, fromViewController: toViewController, toViewController: fromViewController)
    }
    
    func popAnimateInfromViewController(transitionContext: UIViewControllerContextTransitioning!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) {
        
        let fromRows = self.buildRows(viewController: fromViewController)

        toViewController.collectionView.setNeedsLayout()
        toViewController.collectionView.layoutIfNeeded()
        // scroollToSelectedPhotoInDatas必须在DispatchQueue.main.async执行,要不contentoffset不准确
        DispatchQueue.main.async {
            toViewController.scroollToSelectedPhotoInDatas(pre: fromViewController)
            //必须reloaddata,cell的位置才准确
            toViewController.collectionView.reloadData{
                let toRows = self.buildRows(viewController: toViewController, fill: true)
                let (toRowIndex,fromRowIndex,startIndex) =  self.mergeFromRowsToToRows(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController)
               
                self.doPopAnimateInToViewController(fromRows: fromRows, toRows: toRows, fromViewController: fromViewController, toViewController: toViewController, toRowIndex: toRowIndex)
                
                self.doPopAnimateInFromViewController(fromRows: fromRows, toRows: toRows, fromViewController: fromViewController, toViewController: toViewController, fromRowIndex: fromRowIndex, toRowIndex: toRowIndex, startIndex: startIndex)
                
                //        fromViewController.view.alpha = 0
                //        fromViewController.view.isHidden = false
                UIView.animate(withDuration: self.animationDuration,
                               delay:0,
                               animations: {
                                fromViewController.view.alpha = 0
                                //                        fromViewController.view.isHidden = true
                }) { (b) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
    }
    
    func popAnimate(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! FEPhotoBaseCollectionController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! FEPhotoBaseCollectionController
        let container = transitionContext.containerView
        container.backgroundColor = UIColor.clear
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        container.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        self.popAnimateInfromViewController(transitionContext: transitionContext, fromViewController: fromViewController, toViewController: toViewController)
    }
}
