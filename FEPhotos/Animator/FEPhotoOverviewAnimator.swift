//
//  FEPhotoOverviewAnimator.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

public class FEPhotoOverviewAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    var animationDuration: Double! = 0.5
    var operation : UINavigationController.Operation = UINavigationController.Operation.push
    var fromViewController : UIViewController?
    var toViewController : UIViewController?
    var container : UIView?
    
    init(operation : UINavigationController.Operation!, fromVC: UIViewController? , toVC: UIViewController?) {
        super.init()
        self.operation = operation
        self.fromViewController = fromVC
        self.toViewController = toVC
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animationDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let container = transitionContext.containerView
        
        self.fromViewController = fromViewController
        self.toViewController = toViewController
        self.container = container
        
        if (self.operation == .push) {
            self.pushAnimate(using: transitionContext)
        } else if(self.operation == .pop) {
            self.popAnimate(using: transitionContext)
        }
    }
}

extension FEPhotoOverviewAnimator {
    
    func doAnimate(toCell : FEPhotoCell?, zView : UIImageView,transitionContext: UIViewControllerContextTransitioning,fromVC : FEPhotoOverViewController) {
        if  let toCell = toCell {
            // 开始的位置
            let rect = toCell.imageView.convert(toCell.imageView.bounds, to: self.container!)
//            // 维持宽高比例
//            let ratio = toCell.imageView.originResourceAspectRatio
//            if ratio > 0 {
//                rect.size.height = rect.width / ratio
//            }
            let eFrame = rect
            toCell.imageView.isHidden = true
            //                            toCell.imageView.alpha = 0
            let toolBar = fromVC.toolBar
            let thumbnailView = fromVC.thumbnailView
            toolBar.alpha = 1
            thumbnailView.alpha = 1
            
            self.toViewController!.tabBarController!.tabBar.alpha = 1
            toolBar.snp.removeConstraints()
            thumbnailView.snp.removeConstraints()
            toolBar.removeFromSuperview()
            thumbnailView.removeFromSuperview()
            self.toViewController!.tabBarController!.view.addSubview(toolBar)
            self.toViewController!.tabBarController!.view.addSubview(thumbnailView)
            toolBar.snp.makeConstraints { (make) in
                make.left.equalTo(self.toViewController!.tabBarController!.view.safeAreaLayoutGuide.snp.left)
                make.bottom.equalTo(self.toViewController!.tabBarController!.view.safeAreaLayoutGuide.snp.bottom)
                make.right.equalTo(self.toViewController!.tabBarController!.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(49)
            }
            thumbnailView.snp.makeConstraints { (make) in
                make.left.equalTo(self.toViewController!.tabBarController!.view.safeAreaLayoutGuide.snp.left)
                make.bottom.equalTo(toolBar.snp.top)
                make.right.equalTo(self.toViewController!.tabBarController!.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(44)
            }
            
            UIView.animate(withDuration: self.animationDuration / 2,
                           delay: 0,
                           //                                       usingSpringWithDamping: 0.75,
                //                                       initialSpringVelocity: 0,
                options: [],
                animations: {
                    zView.frame = eFrame
//                    toCell.imageView.alpha = 1
            }) { _ in
                toolBar.snp.removeConstraints()
                thumbnailView.snp.removeConstraints()
                toolBar.removeFromSuperview()
                thumbnailView.removeFromSuperview()
                zView.removeFromSuperview()
                toCell.imageView.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            UIView.animate(withDuration: self.animationDuration / 2,
                           delay: 0,
                           animations: {
                            fromVC.view.alpha = 0
                            toolBar.alpha = 0
                            thumbnailView.alpha = 0
//                            fromVC.tabBarController?.tabBar.alpha = 1
            }) { _ in
                
            }
        }
    }
    func popAnimate(using transitionContext: UIViewControllerContextTransitioning) {
         if let fromVC = self.fromViewController as? FEPhotoOverViewController, let toVC = self.toViewController as? FEPhotoBaseCollectionController {
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            container!.insertSubview(toVC.view, belowSubview: fromVC.view)
            container!.backgroundColor = .white
            
            let (row, section) = toVC.findSelectedPhotoInDatas() ?? (-1, -1)
            if (row >= 0) {
                let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: fromVC.pageIndex, section: 0)) as! FEPhotoOverViewCell
                let zView = UIImageView.init(image: cell.imageView.image)// cell.imageView
                zView.contentMode = .scaleAspectFill
                zView.clipsToBounds = true
                let sFrame = cell.imageView.convert(cell.imageView.bounds, to: self.container!)
                zView.frame = sFrame
                cell.imageView.isHidden = true
                self.container!.addSubview(zView)
                
                let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: row, section: section)) as? FEPhotoCell
                if (toCell == nil) {
//                    let cellFrame = toVC.collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath.init(row: row, section: section))?.frame ?? CGRect.zero
//
//                    toVC.collectionView.scrollRectToVisible(cellFrame, animated: false)
                    toVC.collectionView.scrollToItem(at: IndexPath.init(row: row, section: section),
                                                     at: .centeredVertically,
                                                     animated: false)
                    toVC.collectionView.reloadData {
                        let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: row, section: section)) as? FEPhotoCell
                        self.doAnimate(toCell: toCell, zView: zView, transitionContext: transitionContext, fromVC: fromVC)
                    }
                } else {
                    self.doAnimate(toCell: toCell, zView: zView, transitionContext: transitionContext, fromVC: fromVC)
                }
            }
        }
    }
}

extension FEPhotoOverviewAnimator {
    func pushAnimate(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = self.fromViewController as? FEPhotoBaseCollectionController, let toVC = self.toViewController as? FEPhotoOverViewController {
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            toVC.view.layoutSubviews()
            container!.insertSubview(toVC.view, aboveSubview: fromVC.view)
            container!.backgroundColor = .white

            toVC.view.alpha = 0
            toVC.collectionView.isHidden = true
            
            let toolBar = toVC.toolBar
            let thumbnailView = toVC.thumbnailView
            toolBar.alpha = 0
            thumbnailView.alpha = 0

            toolBar.snp.removeConstraints()
            thumbnailView.snp.removeConstraints()
            toolBar.removeFromSuperview()
            thumbnailView.removeFromSuperview()
            fromVC.tabBarController?.view.addSubview(toolBar)
            fromVC.tabBarController?.view.addSubview(thumbnailView)
            toolBar.snp.makeConstraints { (make) in
                make.left.equalTo(fromVC.tabBarController!.view.safeAreaLayoutGuide.snp.left)
                make.bottom.equalTo(fromVC.tabBarController!.view.safeAreaLayoutGuide.snp.bottom)
                make.right.equalTo(fromVC.tabBarController!.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(49)
            }
            thumbnailView.snp.makeConstraints { (make) in
                make.left.equalTo(fromVC.tabBarController!.view.safeAreaLayoutGuide.snp.left)
                make.bottom.equalTo(toolBar.snp.top)
                make.right.equalTo(fromVC.tabBarController!.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(44)
            }
            DispatchQueue.main.async {
                let (preRow, preSection) = fromVC.findSelectedPhotoInDatas() ?? (-1, -1)
                if (preRow >= 0) {
                    let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: preRow, section: preSection)) as! FEPhotoCell
                    let data = fromVC.selectedPhoto
                    let zView = UIImageView.init(image: data?.orginImage)// cell.imageView
                    zView.contentMode = cell.imageView.contentMode
                    zView.clipsToBounds = true
                    // 开始的位置
                    let rect = cell.imageView.convert(cell.imageView.bounds, to: self.container!)
//                    // 维持宽高比例
//                    let ratio = cell.imageView.originResourceAspectRatio
//                    if ratio > 0 {
//                        rect.size.height = rect.width / ratio
//                    }
                    let sFrame = rect
                    let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: toVC.pageIndex, section: 0)) as! FEPhotoOverViewCell
                    let toView = toCell.imageView
                    let eFrame = toView.convert(toView.bounds, to: self.container!)
                    
                    self.container!.addSubview(zView)
                    zView.frame = sFrame
                    zView.transform.scaledBy(x: 1, y: 1)
                    
                    cell.imageView.isHidden = true
                    UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: 0.75,
                                   initialSpringVelocity: 0,
                                   options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState],
                                   animations: {
                                    zView.transform.scaledBy(x: eFrame.width / sFrame.width, y: eFrame.height / sFrame.height)
                                    zView.frame = eFrame
//                                    fromVC.tabBarController?.tabBar.alpha = 0
//                                    toVC.toolBar.alpha = 1
                                    toVC.view.alpha = 1
                                    toolBar.alpha = 1
                                    thumbnailView.alpha = 1
                                    
                    }) { _ in
                        zView.removeFromSuperview()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        cell.imageView.isHidden = false
                        toVC.collectionView.isHidden = false
                        fromVC.view.alpha = 1
                        fromVC.tabBarController?.tabBar.alpha = 0
                        
                        toolBar.snp.removeConstraints()
                        thumbnailView.snp.removeConstraints()
                        toolBar.removeFromSuperview()
                        thumbnailView.removeFromSuperview()
                        toVC.view.addSubview(toolBar)
                        toVC.view.addSubview(thumbnailView)
                        toolBar.snp.makeConstraints { (make) in
                            make.left.equalTo(toVC.view.safeAreaLayoutGuide.snp.left)
                            make.bottom.equalTo(toVC.view.safeAreaLayoutGuide.snp.bottom).offset(49)
                            make.right.equalTo(toVC.view.safeAreaLayoutGuide.snp.right)
                            make.height.equalTo(49)
                        }
                        thumbnailView.snp.makeConstraints { (make) in
                            make.left.equalTo(toVC.view.safeAreaLayoutGuide.snp.left)
                            make.bottom.equalTo(toolBar.snp.top)
                            make.right.equalTo(toVC.view.safeAreaLayoutGuide.snp.right)
                            make.height.equalTo(44)
                        }
                    }
                    UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   animations: {
                                    fromVC.view.alpha = 0
                    }) { _ in
                    }
                }
            }
        }
    }
}

extension UIImageView {
    public var originResourceView: UIView {
        return self
    }
    
    public var originResourceAspectRatio: CGFloat {
        if let image = image, image.size.height > 0 {
            return image.size.width / image.size.height
        }
        if bounds.height > 0 {
            return bounds.width / bounds.height
        }
        return 0
    }
}
