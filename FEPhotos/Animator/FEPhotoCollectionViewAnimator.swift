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
}

class FEPhotoAnimatorRow : NSObject {
    var type : FEPhotoAnimatorRowType = .normal
    var items = [FEPhotoAnimatorRowItem]()
}

class FEPhotoCollectionViewAnimator: NSObject,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    var animationDuration: Double! = 3
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
    
    func pushAnimateIntoViewController(transitionContext: UIViewControllerContextTransitioning!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) {
        
        let fromLayout = fromViewController.collectionViewLayout as! UICollectionViewFlowLayout
        let fromCellSize = fromLayout.itemSize
        
        let savebackgroundColor = toViewController.view.backgroundColor
        
        toViewController.view.backgroundColor = UIColor.clear
        //先让alpha为0,让reloadData的时候看不见cell,如果不设置为0,reloadData的时候会看见cell出现在整个屏幕然后瞬间缩小的效果
        toViewController.view.alpha = 0
        
        toViewController.collectionView.setNeedsLayout()
        toViewController.collectionView.layoutIfNeeded()
        // scroollToSelectedPhotoInDatas必须在DispatchQueue.main.async执行,要不contentoffset不准确
        DispatchQueue.main.async {
            toViewController.scroollToSelectedPhotoInDatas()
            //必须reloaddata,cell的位置才准确
            toViewController.collectionView.reloadData{
                //短时间恢复toViewController.view.alpha,恢复可见
                UIView.animate(withDuration: 0.01, animations: { () -> Void in
                    toViewController.view.alpha = 1
                    toViewController.view.backgroundColor = savebackgroundColor
                })
                UIView.animate(withDuration: self.animationDuration, animations: {
                }) { (b) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
                let (rowSelected, sectionSelected) = toViewController.findSelectedPhotoInDatas() ?? (-1, -1)
                if (rowSelected >= 0) {
                    let frompoint = CGPoint.init(x: toViewController.touchCellCenter.x, y: toViewController.collectionView!.contentOffset.y + toViewController.touchCellCenter.y)
                    
                    if let indexPathsForVisibleCells = toViewController.collectionView?.indexPathsForVisibleItems {
                        //排序
                        let indexPaths = indexPathsForVisibleCells.sorted(by: { (a,b) -> Bool in
                            return a.compare(b) == .orderedAscending
                        })
                        var startcellIndexPath = indexPaths[0]
                        //                            let startcell = toViewController.collectionView.cellForItem(at: startcellIndexPath)
                        var row = 0
                        var col = 0
                        
                        var indexPathRowAndCol = Dictionary<IndexPath,(Int,Int)>()
                        indexPathRowAndCol[startcellIndexPath] = (row,col)
                        
                        var saveRect = Dictionary<IndexPath,CGRect>()
                        //一行的个数
                        let numberInRow = toViewController.controllerType.itemCount()
                        //将cell紧凑排列
                        for indexPath in indexPaths {
                            if (indexPath != startcellIndexPath) {
                                col = indexPath.row % numberInRow
                                if (indexPath.section == startcellIndexPath.section) {
                                    indexPathRowAndCol[indexPath] = (row,col)
                                    if ((indexPath.row + 1) % numberInRow == 0) {
                                        row = row + 1
                                    }
                                } else {
                                    row = row + 1
                                    indexPathRowAndCol[indexPath] = (row,col)
                                }
                                startcellIndexPath = indexPath
                            }
                            let cell = toViewController.collectionView.cellForItem(at: indexPath)
                            saveRect[indexPath] = cell?.frame
                        }
                        var orginx : CGFloat = 0.0
                        var orginy : CGFloat = 0.0
                        var moveSize = CGSize.zero
                        var cells = Dictionary<IndexPath,UICollectionViewCell>()//[UICollectionViewCell]()
                        
                        for indexPath in indexPaths {
                            let sectionheader = toViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                            sectionheader?.isHidden = true
                            let cell = toViewController.collectionView.cellForItem(at: indexPath)
                            let (row,col) = indexPathRowAndCol[indexPath]!
                            orginx = CGFloat(col) * fromCellSize.width
                            orginy = CGFloat(row) * fromCellSize.height
                            cell?.frame = CGRect.init(x: orginx, y: orginy, width: fromCellSize.width, height: fromCellSize.height)
                            //找到移动的cell
                            if (indexPath.row == rowSelected && indexPath.section == sectionSelected) {
                                moveSize = CGSize.init(width: frompoint.x - cell!.center.x ,
                                                       height: frompoint.y - cell!.center.y)
                            }
                            //                                cells.append(cell!)
                            cells[indexPath] = cell
                        }
                        //整体移动
                        for key in cells.keys {
                            let cell = cells[key]! as! FEPhotoCell
                            let width = saveRect[key]!.size.width
                            cell.alpha = 0
                            cell.transform.scaledBy(x: width/fromCellSize.width, y: width/fromCellSize.width)
                            cell.imageView.frame = CGRect.init(x: 0, y: 0, width: fromCellSize.width, height: fromCellSize.height)
                            cell.center = CGPoint.init(x: cell.center.x + moveSize.width,
                                                       y: cell.center.y + moveSize.height)
                        }
                        for indexPath in cells.keys {
                            let item = cells[indexPath] as? FEPhotoCell
                            UIView.animate(withDuration: self.animationDuration,
                                           delay: 0,
                                           usingSpringWithDamping: 0.75,
                                           initialSpringVelocity: 0,
                                           options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                           animations: { () -> Void in
                                            item?.transform.scaledBy(x: 1, y: 1)
                                            item?.alpha = 1
                                            item?.frame = saveRect[indexPath]!
                                            if let frame = item?.frame{
                                                item?.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
                                            }
                                            
                            },
                                           completion: { (b) in
                            })
                        }
                    }
                }
            }
        }
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
    func mergeToRowsToFromRows(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) -> Int {
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
            return fromRowIndex
        }
        return -1
    }
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
                let centery = frame.midY + fromViewController.collectionView.contentOffset.y + FECommon.NavBarHeight
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
                let centery = frame.midY + fromViewController.collectionView.contentOffset.y + FECommon.NavBarHeight
                frame = CGRect.init(x: frame.origin.x,
                                    y: centery - frame.height/2,
                                    width: frame.width,
                                    height: frame.height)
            }
        }
        if let fromSectionheader = fromViewController.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.from.indexPath!) {
            if(!frame.isEmpty) {
                UIView.animate(withDuration: self.animationDuration,
                               delay: 0,
                               usingSpringWithDamping: 0.75,
                               initialSpringVelocity: 0,
                               options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                               animations: { () -> Void in
                                fromSectionheader.alpha = 1
                                fromSectionheader.frame = frame
                },
                               completion: { (b) in
                })
            }
        }
    }
    
    func doPushRowAnimate(row: FEPhotoAnimatorRow!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,
        toRect:[Int:CGRect]!){
        for i in 0...row.items.count - 1 {
            let item = row.items[i]
            if (item.from.isInvented) {
                continue
            }
            if let fromIndexPath = item.from.indexPath {
                // fromIndexPath可能是虚拟的,这里要判断下
                if let fromItem = fromViewController.collectionView.cellForItem(at: fromIndexPath) as? FEPhotoCell{
                    // torect是屏幕的位置,需要转到collection的cotentsize上
                    var frame = toRect[i]!
                    let centery = frame.midY + fromViewController.collectionView.contentOffset.y + FECommon.NavBarHeight
                    frame = CGRect.init(x: frame.origin.x,
                                        y: centery - frame.height/2,
                                        width: frame.width,
                                        height: frame.height)
                    UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: 0.75,
                                   initialSpringVelocity: 0,
                                   options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                   animations: { () -> Void in
                                    fromItem.alpha = 1
                                    fromItem.frame = frame
                                    fromItem.imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
                    },
                                   completion: { (b) in
                    })
                }
            }
        }
        self.doPushAnimateInfromViewControllerWithSection(row: row, fromViewController: fromViewController, toViewController:toViewController, toRect: toRect)
    }
    
    func doPushAnimateInfromViewControllerWithRow(row: FEPhotoAnimatorRow!,startItem: FEPhotoAnimatorRowItem!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) -> CGFloat {
        var startx : CGFloat = MAXFLOAT.cgFloat
        var toRect = [-9999:CGRect.zero]
        if let toIndexPath = startItem.to.indexPath{
            let toCell = toViewController.collectionView.cellForItem(at: toIndexPath)
            let toSize = toCell!.frame.size
            let index = row.items.firstIndex(of: startItem)!
            
            let rect = toCell!.convert(toCell!.bounds, to: UIApplication.shared.keyWindow)
            //相对于屏幕的中心位置
            let toCenter = CGPoint.init(x: rect.midX, y: rect.midY - FECommon.NavBarHeight)
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
                i = i + 1
                x = x + toSize.width
            }
            self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
        }
        return startx
    }
    
    func doPushAnimateInfromViewController(fromRows : [FEPhotoAnimatorRow]? ,toRows : [FEPhotoAnimatorRow]?,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!,fromRowIndex : Int!) {
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
                            let value = self.doPushAnimateInfromViewControllerWithRow(row: row, startItem: item, fromViewController: fromViewController,toViewController: toViewController)
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
                        startFrame.origin.y = startFrame.origin.y - FECommon.NavBarHeight
                    }
                }
                else
                {
                    if let cell = toViewController.collectionView.cellForItem(at: tofirstItem.indexPath!) {
                        let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                        startFrame = rect
                        startFrame.origin.y = startFrame.origin.y - FECommon.NavBarHeight
                    }
                }
                var endFrame = CGRect.zero
                if let cell = toViewController.collectionView.cellForItem(at: tolastItem.indexPath!) {
                    let rect = cell.convert(cell.bounds, to: UIApplication.shared.keyWindow)
                    endFrame = rect
                    endFrame.origin.y = endFrame.origin.y - FECommon.NavBarHeight
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
                            j = j + 1
                            x = x + toSize.width
                        }
//                        let index = fromRows.firstIndex(of: row)!
//                        toRowsRect[index] = toRect
                        self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
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
                            j = j + 1
                            x = x + toSize.width
                        }
//                        let index = fromRows.firstIndex(of: row)!
//                        toRowsRect[index] = toRect
                        self.doPushRowAnimate(row: row, fromViewController: fromViewController, toViewController: toViewController, toRect: toRect)
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
//            self.doPushAnimateInfromViewControllerWithSection(fromRows: fromRows, toRows: toRows, fromViewController: fromViewController, toViewController: toViewController,toRowsRect: toRowsRect)
        }
    }
    
    func pushAnimateInfromViewController(transitionContext: UIViewControllerContextTransitioning!,fromViewController : FEPhotoBaseCollectionController!, toViewController : FEPhotoBaseCollectionController!) {
        
        let fromRows = self.buildRows(viewController: fromViewController, fill: true)
        
        toViewController.collectionView.alpha = 0
        toViewController.collectionView.isHidden = true
        
        toViewController.collectionView.setNeedsLayout()
        toViewController.collectionView.layoutIfNeeded()
        // scroollToSelectedPhotoInDatas必须在DispatchQueue.main.async执行,要不contentoffset不准确
        DispatchQueue.main.async {
            toViewController.scroollToSelectedPhotoInDatas()
            //必须reloaddata,cell的位置才准确
            toViewController.collectionView.reloadData{
                let toRows = self.buildRows(viewController: toViewController)
                let fromRowIndex =  self.mergeToRowsToFromRows(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController)
                // 动画
                self.doPushAnimateInfromViewController(fromRows: fromRows, toRows: toRows,fromViewController: fromViewController,toViewController: toViewController,fromRowIndex: fromRowIndex)

//                UIView.animate(withDuration: self.animationDuration, animations: {
//                }) { (b) in
//
//                }
                
                UIView.animate(withDuration: self.animationDuration,
                               animations: {
                                toViewController.collectionView.alpha = 1
                                toViewController.collectionView.isHidden = false
                }) { (b) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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

//        //开始的view动画
        self.pushAnimateInfromViewController(transitionContext: transitionContext, fromViewController: fromViewController, toViewController: toViewController)
        //结束的view动画
//        self.pushAnimateIntoViewController(transitionContext: transitionContext, fromViewController: fromViewController, toViewController: toViewController)

    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        if (self.operation == .push) {
            self.pushAnimate(using: transitionContext)
//        }
    }
}
