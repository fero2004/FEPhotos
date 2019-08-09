//
//  FEPhotoOverviewAnimator.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import Kingfisher

enum FEPhotoOverviewAnimatorPopType {
    case pan //拖动返回
    case pinch //捏合返回
}

public class FEPhotoOverviewAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    var animationDuration: Double! = 0.5
    var operation : UINavigationController.Operation = UINavigationController.Operation.push
    weak var fromViewController : UIViewController?
    weak var toViewController : UIViewController?
    weak var container : UIView?
    
    var angle : CGFloat = 0.0
    var scale : CGFloat = 0.0
    var changedPoint : CGPoint = .zero
    var indexPath : IndexPath?
    var changedFrame : CGRect = .zero
    var startchangedFrame : Bool = false

    var cellImageView : UIImageView?
    var startFrame : CGRect = .zero
    var backView : UIView?
    weak var toolBar : UIView?
    weak var thumbnailView : UIView?
    weak var transitionContext : UIViewControllerContextTransitioning?
    
    var popType : FEPhotoOverviewAnimatorPopType = .pan
    var toViewPopIndexPath : IndexPath?
    
    public override init() {
        super.init()
    }
    
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
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        self.transitionContext = transitionContext
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let container = transitionContext.containerView
        
        self.fromViewController = fromViewController
        self.toViewController = toViewController
        self.container = container
        
        if (self.operation == .push) {
            if let fromVC = self.fromViewController as? FEPhotoBaseCollectionController, let toVC = self.toViewController as? FEPhotoOverViewController {
                if let cell = fromVC.collectionView.cellForItem(at: self.indexPath ?? IndexPath.init()) as? FEPhotoCell{
                    self.cellImageView = UIImageView()
//                    self.cellImageView?.image = cell.imageView.image
                    self.cellImageView?.kf.setImage(with: FECommon.getLocalFileImageDataProvider(fromVC.selectedPhoto!.orginImagePath!),
                                                    placeholder: nil,
                                                    options: [.loadDiskFileSynchronously],
                                                    progressBlock: nil,
                                                    completionHandler: { (image) in
                    })

                    self.cellImageView?.contentMode = .scaleAspectFill
                    self.cellImageView?.clipsToBounds = true
                    let frame = self.container?.convert(cell.imageView.frame, from: cell.imageView.superview) ?? CGRect.zero
                    self.cellImageView?.frame = frame
                    self.startFrame = frame
                    
                    toVC.view.frame = transitionContext.finalFrame(for: toVC)
                    toVC.view.alpha = 0
                    toVC.collectionView.isHidden = true
                    
                    let toolBar = toVC.toolBar
                    let thumbnailView = toVC.thumbnailView
                    self.toolBar = toolBar
                    self.thumbnailView = thumbnailView
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
                    self.backView = UIView()
                    self.backView?.frame = self.container?.frame ?? .zero
                    self.backView?.backgroundColor = .white
                    self.backView?.alpha = 0
                    
                    container.addSubview(toVC.view)
                    container.addSubview(self.backView!)
                    container.addSubview(self.cellImageView!)
                    
                    var rect = frame
                    //扩大到实际的比列
                    if (cell.imageView.image!.size.width > cell.imageView.image!.size.height) {
                        let value = cell.imageView.image!.size.width / cell.imageView.image!.size.height
                        rect.size.width = rect.size.height * value
                    } else {
                        let value = cell.imageView.image!.size.height / cell.imageView.image!.size.width
                        rect.size.height = rect.size.width * value
                    }
                    rect = CGRect.init(x: frame.midX - rect.width / 2,
                                       y: frame.midY - rect.height / 2,
                                       width: rect.width,
                                       height: rect.height)
                    self.changedFrame = rect
                    self.startchangedFrame = true
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.1,
                                       animations: { [weak self] in
                                        self?.cellImageView?.frame = rect
                        }) { [weak self] (b) in
                            cell.imageView.isHidden = true
                            self?.startchangedFrame = false
                        }
                    }
                }
            }
        } else if(self.operation == .pop) {
            self.startPopInteractiveTransition()
        }
    }
    
    func startPopInteractiveTransition() {
        if let fromVC = self.fromViewController as? FEPhotoOverViewController, let toVC = self.toViewController as? FEPhotoBaseCollectionController {
            let (row, section) = toVC.findSelectedPhotoInDatas() ?? (-1, -1)
            if (row >= 0) {
                self.toViewPopIndexPath = IndexPath.init(row: row, section: section)
                let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: row, section: section)) as? FEPhotoCell
                if (toCell == nil) {
                    toVC.collectionView.scrollToItem(at: IndexPath.init(row: row, section: section),
                                                     at: .centeredVertically,
                                                     animated: false)
                    weak var temptoVc = toVC
                    toVC.collectionView.reloadData {
                        let toCell = temptoVc?.collectionView.cellForItem(at: IndexPath.init(row: row, section: section)) as? FEPhotoCell
                        toCell?.imageView.isHidden = true
                    }
                } else {
                    toCell?.imageView.isHidden = true
                }
                self.backView = UIView()
                self.backView?.frame = self.container?.frame ?? .zero
                self.backView?.backgroundColor = .white
                self.backView?.alpha = 1

                toVC.view.frame = self.transitionContext!.finalFrame(for: toVC)
                toVC.view.alpha = 1

                let toolBar = fromVC.toolBar
                let thumbnailView = fromVC.thumbnailView
                toolBar.alpha = 1
                thumbnailView.alpha = 1

                self.toolBar = toolBar
                self.thumbnailView = thumbnailView

                toVC.tabBarController?.tabBar.alpha = 1
                toolBar.snp.removeConstraints()
                thumbnailView.snp.removeConstraints()
                toolBar.removeFromSuperview()
                thumbnailView.removeFromSuperview()
                toVC.tabBarController?.view.addSubview(toolBar)
                toVC.tabBarController?.view.addSubview(thumbnailView)
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

                fromVC.view.backgroundColor = .clear

                self.container!.backgroundColor = .clear
                self.container!.insertSubview(toVC.view, belowSubview: fromVC.view)
                self.container!.insertSubview(self.backView!, belowSubview: fromVC.view)

                if (self.popType == .pan) {

                } else if(self.popType == .pinch) {
                    if let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: fromVC.pageIndex, section: 0)) as? FEPhotoOverViewCell{
//                        let toView = toCell.imageView ?? UIView.init(frame: CGRect.zero)
//                        let eFrame = toView.convert(toView.bounds, to: self.container!)

                        self.cellImageView = UIImageView()
//                        self.cellImageView?.image = cell.imageView.image
                        self.cellImageView?.kf.setImage(with: FECommon.getLocalFileImageDataProvider(fromVC.selectedPhoto!.orginImagePath!),
                                                        placeholder: nil,
                                                        options: [.loadDiskFileSynchronously],
                                                        progressBlock: nil,
                                                        completionHandler: { (image) in
                        })
                        self.cellImageView?.contentMode = .scaleAspectFill
                        self.cellImageView?.clipsToBounds = true
                        let frame = self.container?.convert(cell.imageView.frame, from: cell.imageView.superview) ?? CGRect.zero
                        self.cellImageView?.frame = frame

                        self.container?.addSubview(self.cellImageView!)

                        cell.imageView.isHidden = true

                        self.changedFrame = frame
                    }
                }
            }
        }
    }
    
    public override func finish() {
        super.finish()
        if (self.operation == .push) {
            if let fromVC = self.fromViewController as? FEPhotoBaseCollectionController, let toVC = self.toViewController as? FEPhotoOverViewController {
                toVC.collectionView.setNeedsLayout()
                toVC.collectionView.layoutIfNeeded()
                
                DispatchQueue.main.async {
                    toVC.collectionView.reloadData() { [weak self] in
                        let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: toVC.pageIndex, section: 0)) as? FEPhotoOverViewCell
                        let toView = toCell?.imageView ?? UIView.init(frame: CGRect.zero)
                        let eFrame = toView.convert(toView.bounds, to: self?.container!)
                        
                        let scaley = eFrame.height / (self?.changedFrame.height ?? 0.1)
                        let scalex = eFrame.width / (self?.changedFrame.width ?? 0.1)

                        var transform = CGAffineTransform.identity
                        transform = CGAffineTransform.init(scaleX: scalex, y: scaley)
                        transform = CGAffineTransform.init(rotationAngle: 0.0).concatenating(transform)
                        
                        UIView.animate(withDuration: 0.3,
                                       animations: {
                                       
                                        self?.cellImageView!.transform = transform
                                        self?.cellImageView?.center = CGPoint.init(x: eFrame.midX, y: eFrame.midY)
                                        toVC.view.alpha = 1.0
                                        toVC.view.isHidden = false
                                        self?.toolBar?.alpha = 1.0
                                        self?.thumbnailView?.alpha = 1.0
                        }) { (b) in
                            UIView.animate(withDuration: 0.0,
                                           animations: {
                                          
                                            
                            }) { (b) in
                                self?.cellImageView?.removeFromSuperview()
                                self?.backView?.removeFromSuperview()
                                self?.toolBar?.removeFromSuperview()
                                self?.backView?.removeFromSuperview()
                                
                                fromVC.view.alpha = 1
                                fromVC.tabBarController?.tabBar.alpha = 0
                                toVC.collectionView.isHidden = false
                                
                                self?.toolBar?.snp.removeConstraints()
                                self?.thumbnailView?.snp.removeConstraints()
                                self?.toolBar?.removeFromSuperview()
                                self?.thumbnailView?.removeFromSuperview()
                                toVC.view.addSubview(self?.toolBar! ?? UIView())
                                toVC.view.addSubview(self?.thumbnailView! ?? UIView())
                                self?.toolBar?.snp.makeConstraints { (make) in
                                    make.left.equalTo(toVC.view.safeAreaLayoutGuide.snp.left)
                                    make.bottom.equalTo(toVC.view.safeAreaLayoutGuide.snp.bottom).offset(49)
                                    make.right.equalTo(toVC.view.safeAreaLayoutGuide.snp.right)
                                    make.height.equalTo(49)
                                }
                                self?.thumbnailView?.snp.makeConstraints { (make) in
                                    make.left.equalTo(toVC.view.safeAreaLayoutGuide.snp.left)
                                    make.bottom.equalTo(self?.toolBar!.snp.top ?? 0)
                                    make.right.equalTo(toVC.view.safeAreaLayoutGuide.snp.right)
                                    make.height.equalTo(44)
                                }
                                if let cell = fromVC.collectionView.cellForItem(at: self?.indexPath ?? IndexPath.init()) as? FEPhotoCell{
                                    cell.imageView.isHidden = false
                                }
                                self?.transitionContext?.completeTransition(true)
                            }
                        }
                    }
                }
            }
        } else if(self.operation == .pop) {
            self.popFinish()
            FECommon.clearCache()
        }
    }
    
    func popFinish() {
        if let fromVC = self.fromViewController as? FEPhotoOverViewController, let toVC = self.toViewController as? FEPhotoBaseCollectionController {
            if (self.popType == .pan) {
                if let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: fromVC.pageIndex, section: 0)) as? FEPhotoOverViewCell, let toCell = toVC.collectionView.cellForItem(at: self.toViewPopIndexPath ?? IndexPath()) as? FEPhotoCell{
                    let toView = toCell.imageView ?? UIView.init(frame: CGRect.zero)
                    let eFrame = toView.convert(toView.bounds, to: self.container!)
                    
                    self.cellImageView = UIImageView()
//                    self.cellImageView?.image = cell.imageView.image
                    self.cellImageView?.kf.setImage(with: FECommon.getLocalFileImageDataProvider(fromVC.selectedPhoto!.orginImagePath!),
                                                    placeholder: nil,
                                                    options: [.loadDiskFileSynchronously],
                                                    progressBlock: nil,
                                                    completionHandler: { (image) in
                    })
                    self.cellImageView?.contentMode = .scaleAspectFill
                    self.cellImageView?.clipsToBounds = true
                    let frame = self.container?.convert(cell.imageView.frame, from: cell.imageView.superview) ?? CGRect.zero
                    self.cellImageView?.frame = frame
                    
                    self.container?.addSubview(self.cellImageView!)
                    
                    cell.imageView.isHidden = true
                    
                    UIView.animate(withDuration: 0.3,
                                   animations: { [weak self] in
                                    self?.backView?.alpha = 0.0
                                    self?.cellImageView?.frame = eFrame
                                    self?.toolBar?.alpha = 0
                                    self?.thumbnailView?.alpha = 0
                    }) { [weak self] (b) in
                        self?.cellImageView?.removeFromSuperview()
                        self?.backView?.removeFromSuperview()
                        self?.toolBar?.snp.removeConstraints()
                        self?.thumbnailView?.snp.removeConstraints()
                        self?.toolBar?.removeFromSuperview()
                        self?.thumbnailView?.removeFromSuperview()
                        toCell.imageView.isHidden = false
                        self?.transitionContext?.completeTransition(true)
                    }
                }
            } else if(self.popType == .pinch) {
                if let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: fromVC.pageIndex, section: 0)) as? FEPhotoOverViewCell, let toCell = toVC.collectionView.cellForItem(at: self.toViewPopIndexPath ?? IndexPath()) as? FEPhotoCell{
//                    self.cellImageView?.contentMode = .scaleToFill
                    let toView = toCell.imageView ?? UIView.init(frame: CGRect.zero)
                    let eFrame = toView.convert(toView.bounds, to: self.container!)
                    
//                    let scaley = eFrame.height / self.changedFrame.height
//                    let scalex = eFrame.width / self.changedFrame.width
                    
                    var transform = CGAffineTransform.identity
//                    transform = CGAffineTransform.init(scaleX: scalex, y: scaley)
                    transform = CGAffineTransform.init(rotationAngle: 0.0).concatenating(transform)
                    
                    UIView.animate(withDuration: 0.3,
                                   animations: {[weak self] in
                                    
                                    self?.cellImageView?.transform = transform
                                    self?.cellImageView?.frame = eFrame
                                    toVC.view.alpha = 1.0
                                    toVC.view.isHidden = false
                                    self?.toolBar?.alpha = 0
                                    self?.thumbnailView?.alpha = 0
                                    self?.backView?.alpha = 0.0
                    }) { [weak self](b) in
                        self?.cellImageView?.removeFromSuperview()
                        self?.backView?.removeFromSuperview()
                        
                        toVC.tabBarController?.tabBar.alpha = 1
                        toVC.collectionView.isHidden = false
                        
                        self?.toolBar?.snp.removeConstraints()
                        self?.thumbnailView?.snp.removeConstraints()
                        self?.toolBar?.removeFromSuperview()
                        self?.thumbnailView?.removeFromSuperview()
                       
                        toCell.imageView.isHidden = false
                        self?.transitionContext?.completeTransition(true)
                    }
                }
            }
        }
    }
    
    public override func cancel() {
        super.cancel()
        if (self.operation == .push) {
            UIView.animate(withDuration: self.animationDuration / 2,
                           animations: { [weak self] in
                            self?.cellImageView?.transform = CGAffineTransform.identity
                            self?.cellImageView?.frame = self?.startFrame ?? CGRect.zero
                            self?.toolBar?.alpha = 0.0
                            self?.thumbnailView?.alpha = 0.0
                            self?.backView?.alpha = 0.0
            }) { [weak self](b) in
                self?.toolBar?.removeFromSuperview()
                self?.thumbnailView?.removeFromSuperview()
                self?.backView?.removeFromSuperview()
                self?.cellImageView?.removeFromSuperview()
                if let fromVC = self?.fromViewController as? FEPhotoBaseCollectionController{
                    if let cell = fromVC.collectionView.cellForItem(at: self?.indexPath ?? IndexPath.init()) as? FEPhotoCell{
                        cell.imageView.isHidden = false
                    }
                }
                self?.transitionContext?.completeTransition(false)
            }
        } else if(self.operation == .pop) {
            self.popCancel()
        }
    }
    
    func popCancel() {
        if let fromVC = self.fromViewController as? FEPhotoOverViewController, let toVC = self.toViewController as? FEPhotoBaseCollectionController {
            let toCell = toVC.collectionView.cellForItem(at: self.toViewPopIndexPath ?? IndexPath()) as? FEPhotoCell
            let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: fromVC.pageIndex, section: 0)) as? FEPhotoOverViewCell

            if (self.popType == .pan) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                    self.toViewPopIndexPath = IndexPath.init(row: row, section: section)
                    fromVC.view.backgroundColor = .white
                    fromVC.view.alpha = 1
                    toVC.tabBarController?.tabBar.alpha = 0
                    //                    toVC.collectionView.isHidden = false
                    self.toolBar?.snp.removeConstraints()
                    self.thumbnailView?.snp.removeConstraints()
                    self.toolBar?.removeFromSuperview()
                    self.thumbnailView?.removeFromSuperview()
                    fromVC.view.addSubview(self.toolBar!)
                    fromVC.view.addSubview(self.thumbnailView!)
                    self.toolBar?.snp.makeConstraints { (make) in
                        make.left.equalTo(fromVC.view.safeAreaLayoutGuide.snp.left)
                        make.bottom.equalTo(fromVC.view.safeAreaLayoutGuide.snp.bottom).offset(49)
                        make.right.equalTo(fromVC.view.safeAreaLayoutGuide.snp.right)
                        make.height.equalTo(49)
                    }
                    self.thumbnailView?.snp.makeConstraints { (make) in
                        make.left.equalTo(fromVC.view.safeAreaLayoutGuide.snp.left)
                        make.bottom.equalTo(self.toolBar!.snp.top)
                        make.right.equalTo(fromVC.view.safeAreaLayoutGuide.snp.right)
                        make.height.equalTo(44)
                    }
                    cell?.imageView.isHidden = false
                    toCell?.imageView.isHidden = false
                    self.transitionContext?.completeTransition(false)
                }
            } else if(self.popType == .pinch) {
                let transform = CGAffineTransform.identity
                let view = cell ?? UIView.init(frame: CGRect.zero)
                let frame = view.convert(view.bounds, to: self.container!)
                UIView.animate(withDuration: 0.3,
                               animations: { [weak self] in
                                toVC.tabBarController?.tabBar.alpha = 0
                                self?.backView?.alpha = 1.0
                                self?.cellImageView?.center = CGPoint.init(x: frame.midX, y: frame.midY)
//                                self?.cellImageView?.frame = frame
                                self?.cellImageView?.transform = transform
                }) { [weak self](b) in
                    self?.cellImageView?.removeFromSuperview()
                    self?.backView?.removeFromSuperview()
                    
                    fromVC.view.alpha = 1
                    fromVC.view.backgroundColor = .white
                    
                    toVC.collectionView.isHidden = false
                    
                    self?.toolBar?.snp.removeConstraints()
                    self?.thumbnailView?.snp.removeConstraints()
                    self?.toolBar?.removeFromSuperview()
                    self?.thumbnailView?.removeFromSuperview()
                    fromVC.view.addSubview(self?.toolBar! ?? UIView())
                    fromVC.view.addSubview(self?.thumbnailView! ?? UIView())
                    self?.toolBar?.snp.makeConstraints { (make) in
                        make.left.equalTo(fromVC.view.safeAreaLayoutGuide.snp.left)
                        make.bottom.equalTo(fromVC.view.safeAreaLayoutGuide.snp.bottom).offset(49)
                        make.right.equalTo(fromVC.view.safeAreaLayoutGuide.snp.right)
                        make.height.equalTo(49)
                    }
                    self?.thumbnailView?.snp.makeConstraints { (make) in
                        make.left.equalTo(fromVC.view.safeAreaLayoutGuide.snp.left)
                        make.bottom.equalTo(self?.toolBar!.snp.top ?? 0)
                        make.right.equalTo(fromVC.view.safeAreaLayoutGuide.snp.right)
                        make.height.equalTo(44)
                    }
                    toCell?.imageView.isHidden = false
                    cell?.imageView.isHidden = false
                    self?.transitionContext?.completeTransition(false)
                }
            }
        }
    }
    
    public override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        if (self.operation == .push) {
            if (self.startchangedFrame) {
                return
            }
            self.cellImageView?.center = CGPoint.init(x: (self.cellImageView?.center.x ?? 0.0)-self.changedPoint.x, y: (self.cellImageView?.center.y ?? 0.0)-self.changedPoint.y)
            
            let currentScale: CGFloat = self.cellImageView?.layer.value(forKeyPath: "transform.scale.x") as? CGFloat ?? 0.0
            let fullScreenScale = (self.toViewController?.view.bounds.width ?? 0.0) / self.changedFrame.width
            
            let percent = (currentScale - 1) / (fullScreenScale - 1)
            
            self.backView?.alpha = percent
            self.toolBar?.alpha = percent
            self.thumbnailView?.alpha = percent
            
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = fullScreenScale * 2
            let zoomSpeed: CGFloat = 1.5
            
//            print(currentScale)
//            print(fullScreenScale)
            
            var deltaScale = self.scale

            deltaScale = ((deltaScale - 1) * zoomSpeed) + 1
            deltaScale = min(deltaScale, maxScale / currentScale)
            deltaScale = max(deltaScale, minScale / currentScale)
            
            let zoomTransform = (self.cellImageView?.transform)!.scaledBy(x: deltaScale, y: deltaScale)
            self.cellImageView?.transform = zoomTransform
            
            self.cellImageView?.transform = (self.cellImageView?.transform)!.rotated(by: self.angle)
        } else if(self.operation == .pop) {
            self.popUpdate(percentComplete)
        }
    }
    
    func popUpdate(_ percentComplete: CGFloat) {
        if let fromVC = self.fromViewController as? FEPhotoOverViewController, let toVC = self.toViewController as? FEPhotoBaseCollectionController {
            if (self.popType == .pan) {
                self.toolBar?.alpha = percentComplete
                self.thumbnailView?.alpha = percentComplete
                self.backView?.alpha = percentComplete
            } else if(self.popType == .pinch) {
                let s = (1 - percentComplete)
                self.toolBar?.alpha = s
                self.thumbnailView?.alpha = s
                self.backView?.alpha = s

                 self.cellImageView?.center = CGPoint.init(x: (self.cellImageView?.center.x ?? 0.0)-self.changedPoint.x, y: (self.cellImageView?.center.y ?? 0.0)-self.changedPoint.y)
                self.cellImageView?.transform = CGAffineTransform.init(scaleX: self.scale, y: self.scale)
                self.cellImageView?.transform = (self.cellImageView?.transform)!.rotated(by: self.angle)
            }
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
                FECommon.clearCache()
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
                    toVC.collectionView.reloadData { [weak self] in
                        let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: row, section: section)) as? FEPhotoCell
                        self?.doAnimate(toCell: toCell, zView: zView, transitionContext: transitionContext, fromVC: fromVC)
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
//            toVC.collectionView.setNeedsLayout()
//            toVC.collectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                toVC.collectionView.reloadData() { [weak self] in
                    let (preRow, preSection) = fromVC.findSelectedPhotoInDatas() ?? (-1, -1)
                    if (preRow >= 0) {
                        let cell = fromVC.collectionView.cellForItem(at: IndexPath.init(row: preRow, section: preSection)) as! FEPhotoCell
                        let data = fromVC.selectedPhoto
                        let zView = UIImageView.init()// cell.imageView
                        zView.kf.setImage(with: FECommon.getLocalFileImageDataProvider(data!.orginImagePath!),
                                                 placeholder: nil,
                                                 options: [.loadDiskFileSynchronously],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
                        zView.contentMode = cell.imageView.contentMode
                        zView.clipsToBounds = true
                        // 开始的位置
                        let rect = cell.imageView.convert(cell.imageView.bounds, to: self?.container!)
                        //                    // 维持宽高比例
                        //                    let ratio = cell.imageView.originResourceAspectRatio
                        //                    if ratio > 0 {
                        //                        rect.size.height = rect.width / ratio
                        //                    }
                        let sFrame = rect
                        let toCell = toVC.collectionView.cellForItem(at: IndexPath.init(row: toVC.pageIndex, section: 0)) as! FEPhotoOverViewCell
                        let toView = toCell.imageView
                        let eFrame = toView.convert(toView.bounds, to: self?.container!)
                        
                        print(eFrame)

                        self?.container!.addSubview(zView)
                        zView.frame = sFrame
                        zView.transform.scaledBy(x: 1, y: 1)
                        
                        UIView.animate(withDuration: self?.animationDuration ?? 0,
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
                                        self?.backView?.alpha = 0
                                        
                        }) { _ in
                            cell.imageView.isHidden = true
                            zView.removeFromSuperview()
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
                          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        }
                        UIView.animate(withDuration: self?.animationDuration ?? 0,
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
