//
//  FEPhotoOverViewCell.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import Kingfisher

class FEPhotoOverViewCell: UICollectionViewCell {
    
    /// ImageView
    open var imageView = UIImageView()
    
//    var isPullUp : Bool = false
    
    var isShowDetail : Bool = false
    
    var photo : FEPhotoCellData?
    
    var pullUpView : FEPhotoOverViewPullUpView?
    var isDissMissPullUpView : Bool = true
    /// 图片缩放容器
    open var imageContainer = UIScrollView()
    
    /// 图片允许的最大放大倍率
    open var imageMaximumZoomScale: CGFloat = 2.0
    
    /// 单击时回调
    open var clickCallback: ((UITapGestureRecognizer) -> Void)?
    
    /// 长按时回调
    open var longPressedCallback: ((UILongPressGestureRecognizer) -> Void)?
    
    /// 图片拖动时回调
    open var panChangedCallback: ((_ scale: CGFloat) -> Void)?
    
    /// 图片拖动松手回调。isDown: 是否向下
    open var panReleasedCallback: ((_ isDown: Bool) -> Void)?
    
    // 捏合手势
    open var pinchCallback: ((_ pinch:FEPhotoIndexPinchGestureRecognizer,_ scrollview: UIScrollView) -> Void)?
    
    // 旋转手势
    open var rotateCallback: ((_ rotate: UIRotationGestureRecognizer)  -> Void)?
    
    //是否在做pop动画
    open var isPop: (() -> Bool)?
    
    /// 是否需要添加长按手势。子类可重写本属性，返回`false`即可避免添加长按手势
    open var isNeededLongPressGesture: Bool {
        return true
    }
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    /// 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageContainer)
        imageContainer.maximumZoomScale = imageMaximumZoomScale
        imageContainer.delegate = self
        imageContainer.showsVerticalScrollIndicator = false
        imageContainer.showsHorizontalScrollIndicator = false
//        imageContainer.pinchGestureRecognizer?.delegate = self
        if #available(iOS 11.0, *) {
            imageContainer.contentInsetAdjustmentBehavior = .never
        }
        
        imageContainer.addSubview(imageView)
        imageView.clipsToBounds = true
        
        self.addGesture()
        // 子类作进一步初始化
        didInit()
    }
    
    func addGesture() {
        // 长按手势
        if isNeededLongPressGesture {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
            contentView.addGestureRecognizer(longPress)
        }
        // 双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleClick(_:)))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
        
        // 单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onClick(_:)))
        contentView.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
        
        // 拖动手势
        let pan = FEPhotoPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.cancelsTouchesInView = false
        pan.delegate = self
        pan.maximumNumberOfTouches = 1
        // 必须加在图片容器上。不能加在contentView上，否则长图下拉不能触发
        imageContainer.addGestureRecognizer(pan)
        
        //捏合手势
        let pinch = FEPhotoIndexPinchGestureRecognizer.init(target: self, action: #selector(userDidPinch(_ : )))
        //        pinch.indexPath = indexPath
        pinch.delegate = self
        contentView.addGestureRecognizer(pinch)
        //旋转手势
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(userDidRoate(_:)))
        rotate.delegate = self
        contentView.addGestureRecognizer(rotate)
    }
    
    @objc func userDidRoate(_ recognizer : UIRotationGestureRecognizer) {
        if self.pullUpView?.isShowUp ?? false {
            return
        }
        if (self.rotateCallback != nil) {
            self.rotateCallback!(recognizer)
        }
    }
    
    @objc func userDidPinch(_ recognizer : FEPhotoIndexPinchGestureRecognizer) {
        if self.pullUpView?.isShowUp ?? false{
            return
        }
        if (self.pinchCallback != nil) {
            self.pinchCallback!(recognizer,self.imageContainer)
        }
        
    }
    
    /// 初始化完成时调用，空实现。子类可重写本方法以作进一步初始化
    open func didInit() {
        // 子类重写
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageContainer.frame = contentView.bounds
        imageContainer.setZoomScale(1.0, animated: false)
        imageView.frame = fitFrame
        imageContainer.setZoomScale(1.0, animated: false)
    }
}

extension FEPhotoOverViewCell {
    /// 计算图片复位坐标
    private var resettingCenter: CGPoint {
        let deltaWidth = bounds.width - imageContainer.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = bounds.height - imageContainer.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: imageContainer.contentSize.width * 0.5 + offsetX,
                       y: imageContainer.contentSize.height * 0.5 + offsetY)
    }
    
    /// 计算图片适合的size
    var fitSize: CGSize {
//        guard let image = imageView.image else {
//            return CGSize.zero
//        }
        let image = CGRect.init(x: 0, y: 0, width: self.photo?.orginImageSize.width ?? 0.1, height: self.photo?.orginImageSize.height ?? 0.1)
        var width: CGFloat
        var height: CGFloat
        if imageContainer.bounds.width < imageContainer.bounds.height {
            // 竖屏
            width = imageContainer.bounds.width
            height = (image.size.height / image.size.width) * width
        } else {
            // 横屏
            height = imageContainer.bounds.height
            width = (image.size.width / image.size.height) * height
            if width > imageContainer.bounds.width {
                width = imageContainer.bounds.width
                height = (image.size.height / image.size.width) * width
            }
        }
        return CGSize(width: width, height: height)
    }
    
    /// 计算图片适合的frame
    private var fitFrame: CGRect {
        let size = fitSize
        let y = imageContainer.bounds.height > size.height
            ? (imageContainer.bounds.height - size.height) * 0.5 : 0
        let x = imageContainer.bounds.width > size.width
            ? (imageContainer.bounds.width - size.width) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    /// 复位ImageView
    func resetImageView() {
        // 如果图片当前显示的size小于原size，则重置为原size
        let size = fitSize
        let needResetSize = imageView.bounds.size.width < size.width
            || imageView.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
            self.imageView.center = self.resettingCenter
            if needResetSize {
                self.imageView.bounds.size = size
            }
        }
    }
}

//
// MARK: - Events
//

extension FEPhotoOverViewCell {
    /// 响应拖动
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard imageView.image != nil else {
            return
        }
        let isPullUp_1 = pan.velocity(in: self).y < 0 && self.imageContainer.zoomScale == 1
        let isPullUp_not_1 = pan.velocity(in: self).y < 0 && self.imageContainer.zoomScale != 1
        let isPullDown_1 = pan.velocity(in: self).y > 0 && self.imageContainer.zoomScale == 1
        let isPullDown_not_1 = pan.velocity(in: self).y > 0 && self.imageContainer.zoomScale != 1
        var ispop = false
        if (self.isPop != nil) {
            ispop = self.isPop!()
        }
        if (((isPullDown_1 || isPullDown_not_1) && !isShowDetail) || ispop) {
            switch pan.state {
            case .began:
                if let collectionView = self.superview as? UICollectionView {
                    collectionView.isScrollEnabled = false
                }
                beganFrame = imageView.frame
                beganTouch = pan.location(in: imageContainer)
            case .changed:
                let result = panResult(pan)
                imageView.frame = result.0
                panChangedCallback?(result.1)
            case .ended, .cancelled:
                imageView.frame = panResult(pan).0
                let isDown = pan.velocity(in: self).y > 0
                self.panReleasedCallback?(isDown)
                if !isDown {
                    resetImageView()
                }
                if let collectionView = self.superview as? UICollectionView {
                    collectionView.isScrollEnabled = true
                }
            default:
                resetImageView()
            }
        }
        else if (isPullUp_1 || isPullDown_1){
            switch pan.state {
            case .began:
                if let collectionView = self.superview as? UICollectionView {
                    collectionView.isScrollEnabled = false
                }
                isShowDetail = true
                beganFrame = imageView.frame
                beganTouch = pan.location(in: imageContainer)
                if (isPullUp_1 && isDissMissPullUpView) {
                    self.showPullUpView()
                }
            case .changed:
                let result = panResult(pan)
                imageView.center.y = result.0.midY
                self.pullUpView?.frame = CGRect.init(x: 0, y: imageView.frame.maxY, width: self.frame.width, height: self.frame.height)
                self.pullUpView?.changeContenInsert(insert: 0)
                self.pullUpView?.changeContentOffsetBlock = nil
                self.pullUpView?.isShowUp = false
                self.imageContainer.pinchGestureRecognizer?.isEnabled = true
            case .ended, .cancelled:
                self.endAnimation(isPullUp_1: isPullUp_1)
            default:
                resetImageView()
            }
        }
    }
    
    func endAnimation(isPullUp_1 : Bool) {
        var height = imageView.frame.height
        var frame = CGRect.zero
        var offset : CGFloat = 0.0
        if (imageView.frame.height < self.contentView.height) {
            frame = CGRect.init(x: imageView.frame.origin.x,
                                    y: FECommon.NavBarHeight - height / 2,
                                    width: imageView.width,
                                    height: height)
            offset = (FECommon.NavBarHeight + height / 2)
        } else {
            height = self.contentView.height
            frame = CGRect.init(x: imageView.frame.origin.x,
                                    y: (FECommon.NavBarHeight + height / 2) - height,
                                    width: imageView.width,
                                    height: height)
            offset = (FECommon.NavBarHeight + height / 2)
        }
        if (isPullUp_1) {
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.frame = frame
                self.pullUpView?.frame = CGRect.init(x: 0, y: self.imageView.frame.maxY, width: self.frame.width, height: self.frame.height)

            }) { (b) in
                self.pullUpView?.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                self.pullUpView?.changeContenInsert(insert: offset)
                self.imageContainer.pinchGestureRecognizer?.isEnabled = false
                self.pullUpView?.isShowUp = true
                self.pullUpView?.changeContentOffsetBlock = { [weak self] offset in
                    self?.imageView.center.y = (self?.imageView.center.y ?? 0) + offset
                }
            }
        } else {
            resetImageView()
            self.disMissPullUpView()
            isShowDetail = false
        }
        if let collectionView = self.superview as? UICollectionView {
            collectionView.isScrollEnabled = true
        }
    }
    
    func showPullUpView() {
        isDissMissPullUpView = false
        self.pullUpView?.removeFromSuperview()
        self.pullUpView = nil
        self.pullUpView = FEPhotoOverViewPullUpView.init(frame: CGRect.init(x: 0, y: self.frame.height, width: self.frame.width, height: self.frame.height))
        self.pullUpView?.cell = self
//        self.imageContainer.addSubview(self.pullUpView ?? UIView())
        self.imageContainer.insertSubview(self.pullUpView ?? UIView(), belowSubview: self.imageView)
        UIView.animate(withDuration: 0.2) {
            self.pullUpView?.frame = CGRect.init(x: 0, y: self.imageView.frame.maxY, width: self.frame.width, height: self.frame.height)
        }
    }
    
    func pullUpReset() {
        self.resetImageView()
        self.disMissPullUpView()
    }
    
    func disMissPullUpView() {
        isDissMissPullUpView = true
        UIView.animate(withDuration: 0.2) {
            self.pullUpView?.frame = CGRect.init(x: 0, y: self.frame.maxY, width: self.frame.width, height: self.frame.height)
            
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (CGRect, CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: imageContainer)
        let currentTouch = pan.location(in: imageContainer)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    /// 响应单击
    @objc private func onClick(_ tap: UITapGestureRecognizer) {
        clickCallback?(tap)
    }
    
    /// 响应双击
    @objc private func onDoubleClick(_ tap: UITapGestureRecognizer) {
        // 如果当前没有任何缩放，则放大到目标比例，否则重置到原比例
        if imageContainer.zoomScale == 1.0 {
            // 以点击的位置为中心，放大
            let pointInView = tap.location(in: imageView)
            let width = imageContainer.bounds.size.width / imageContainer.maximumZoomScale
            let height = imageContainer.bounds.size.height / imageContainer.maximumZoomScale
            let x = pointInView.x - (width / 2.0)
            let y = pointInView.y - (height / 2.0)
            imageContainer.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
        } else {
            imageContainer.setZoomScale(1.0, animated: true)
        }
    }
    
    /// 响应长按
    @objc private func onLongPress(_ press: UILongPressGestureRecognizer) {
        if press.state == .began {
            longPressedCallback?(press)
        }
    }
}

//
// MARK: - UIScrollViewDelegate
//

extension FEPhotoOverViewCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = resettingCenter
    }
    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//
//    }
}


//
// MARK: - UIGestureRecognizerDelegate
//

extension FEPhotoOverViewCell: UIGestureRecognizerDelegate {
  
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer.view is FETableView) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var ispop = false
        if (self.isPop != nil) {
            ispop = self.isPop!()
        }
        if (ispop) {
            if (gestureRecognizer is FEPhotoIndexPinchGestureRecognizer) {
                return true
            } else {
                return false
            }
        } else {
            if (gestureRecognizer is FEPhotoIndexPinchGestureRecognizer) {
                if (gestureRecognizer is FEPhotoIndexPinchGestureRecognizer && self.imageContainer.zoomScale == 1.0) {
                    return true
                } else {
                    return false
                }
            }
        }
        return true
    }
  
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只响应pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            //放大的情况下不相应pan手势
            if(self.imageContainer.zoomScale != 1) {
                return false
            }
        }

        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            //向上滑动,显示下面的更多view
            if(self.imageContainer.zoomScale == 1) {
                //https://stackoverflow.com/questions/7100884/uipangesturerecognizer-only-vertical-or-horizontal/8603839
                /*
                 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
                 {
                 if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                 
                 UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
                 CGPoint velocity = [panGesture velocityInView:panGesture.view];
                 
                 double radian = atan(velocity.y/velocity.x);
                 double degree = radian * 180 / M_PI;
                 
                 double thresholdAngle = 20.0;
                 if (fabs(degree) > enableThreshold) {
                 return NO;
                 }
                 }
                 return YES;
                 }
                 */
                //不是完全向上,手指有个角度,在这角度上响应向上的手势
                let radian = atan2(velocity.y, velocity.x)
                let degree = radian * 180.0 / Double.pi.cgFloat
                if (abs(degree) > 60 && abs(degree) < 120) {
                    return true
                }
            }
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 向下滑动，如果图片顶部超出可视区域，不响应手势
        if imageContainer.contentOffset.y > 0 {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
    }
}

