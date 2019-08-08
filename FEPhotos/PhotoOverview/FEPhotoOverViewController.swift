//
//  FEPhotoOverViewController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import Kingfisher

class FEPhotoOverViewController: UIViewController, FEAnimatorDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching{

    //手势交互
    var transition : FEPhotoOverviewAnimator?
    /// 左右两张图之间的间隙
    open var photoSpacing: CGFloat = 30
    
    var selectedPhoto : FEPhotoCellData?
    
    //原始数据
    var photos : [FEPhotoCellData] = [FEPhotoCellData]()
    
    let thumbnailView = PhotoOverviewThumbnailView()
    let toolBar = PhotoOverviewToolBar()
    
//    var doPopAnimate : Bool = false
    
    /// 是否需要遮盖状态栏。默认false
    open var isNeedCoverStatusBar = false
    
    /// 保存原windowLevel
    open var originWindowLevel: UIWindow.Level?
    var lastPoint = CGPoint.zero
    // 表示了当前显示图片的序号，从0开始计数
    open var pageIndex: Int = 0 {
        didSet {
            if pageIndex != oldValue {
                self.selectedPhoto = self.photos[pageIndex]
                thumbnailView.selectedPhoto = self.selectedPhoto
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectedPhotoChanged"),
                                                object: self.selectedPhoto)
            }
        }
    }
    
    /// 流型布局
    open lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    /// 容器
    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.isPrefetchingEnabled=true    //预取开关
        collectionView.prefetchDataSource=self   //预取数据源
        return collectionView
    }()
    
    func animatorType() -> FEAnimatorType {
        return .overview
    }
    
    func interactionTransition() -> FEPhotoOverviewAnimator? {
        return self.transition
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FEPhotoOverViewCell.self, forCellWithReuseIdentifier: "FEPhotoOverViewCell")
        
        self.pageIndex = self.photos.index(of: self.selectedPhoto ?? FEPhotoCellData()) ?? 0
        
        thumbnailView.selectedPhoto = self.selectedPhoto
        thumbnailView.photos = self.photos
        thumbnailView.didEndDeceleratingBlock = {[weak self] in
            if let cell = self?.collectionView.cellForItem(at: IndexPath.init(row: self?.pageIndex ?? 0, section: 0)) as? FEPhotoOverViewCell {
                let data = self?.photos[self?.pageIndex ?? 0]
                cell.imageView.kf.setImage(with: LocalFileImageDataProvider.init(fileURL: URL.init(fileURLWithPath: Bundle.main.path(forResource: data?.orginImagePath!, ofType: nil)!)),
                                           placeholder: cell.imageView.image,
                                           options: [.loadDiskFileSynchronously],
                                           progressBlock: nil,
                                           completionHandler: { (image) in
                                            cell.setNeedsLayout()
                })
            }
        }
        view.addSubview(thumbnailView)
        view.addSubview(toolBar)
        let item1 = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(upload))
        let item2 = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: self, action: #selector(like))
        let item3 = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(trash))
        // Do any additional setup after loading the view.
        toolBar.items = [item1,UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         item2,UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         item3]
        toolBar.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(49)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.height.equalTo(49)
        }
        thumbnailView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.height.equalTo(44)
        }
        self.thumbnailView.didSelectPhoto = { [weak self](p,animated,contact) in
            self?.selectedPhoto = p
            self?.pageIndex = self?.photos.firstIndex(of: p)! ?? 0
            self?.scrollToItem(self?.pageIndex ?? 0, at: .left, animated: animated,contact:contact)
        }
    }
    
    @objc func upload(item : UIBarButtonItem) {
        
    }
    
    @objc func like(item : UIBarButtonItem) {
        
    }
    
    @objc func trash(item : UIBarButtonItem) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let index = pageIndex
        setLayout()
        self.thumbnailView.setNeedsLayout()
        if (self.transition == nil) {
            collectionView.reloadData { [weak self] in
                self?.collectionView.layoutIfNeeded()
                self?.scrollToItem(index, at: .left, animated: false)
                self?.collectionView.layoutIfNeeded()
            }
        }
    }
    
    /// 滑到哪张图片
    /// - parameter index: 图片序号，从0开始
    open func scrollToItem(_ index: Int, at position: UICollectionView.ScrollPosition, animated: Bool,contact : Bool = true) {
        var safeIndex = max(0, index)
        safeIndex = min(self.photos.count - 1, safeIndex)
        let indexPath = IndexPath(item: safeIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
        if (contact) {
            let index = self.pageIndex
            let currect = self.photos[index]
            var next : FEPhotoCellData?
            if (index + 1 <= self.photos.count - 1) {
                next = self.photos[index + 1]
            }
            self.thumbnailView.overViewScrollViewDidScroll(collectionView, currect: currect, currectPersent: 1.0, next: next, nextPersent: 0.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    /// scrollView滑动
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var value: CGFloat = 0
//        if isRTLLayout {
//            value = (scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.bounds.width / 2) / scrollView.bounds.width
//        } else {
            value = (scrollView.contentOffset.x + scrollView.bounds.width / 2) / scrollView.bounds.width
//        }
        var index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if (index < 0) {
            index = 0
        } else if(index >= self.photos.count - 1) {
            index = self.photos.count - 1
        }
        
        var nextPersent : CGFloat = 0.0
        var currectPersent : CGFloat = 0.0
        let cellAttr = self.collectionView.layoutAttributesForItem(at: IndexPath.init(row: index, section: 0))
        let rect = CGRect.init(x: cellAttr!.frame.origin.x,
                               y: cellAttr!.frame.origin.y,
                               width: cellAttr!.frame.width + photoSpacing,
                               height: cellAttr!.frame.height)
        let temprect = rect.intersection(self.collectionView.bounds)
        currectPersent = temprect.width / self.collectionView.bounds.width
        nextPersent = 1.0 - currectPersent
 
        let currect = self.photos[index]
        var next : FEPhotoCellData?
        if (index + 1 <= self.photos.count - 1) {
            next = self.photos[index + 1]
        }
        self.thumbnailView.overViewScrollViewDidScroll(scrollView, currect: currect, currectPersent: currectPersent, next: next, nextPersent: nextPersent)
        
        self.pageIndex = max(0, Int(value))
    }
    
    private func setLayout() {
        flowLayout.minimumLineSpacing = photoSpacing
        flowLayout.itemSize = view.bounds.size
        collectionView.frame = view.bounds
        collectionView.frame.size.width = view.bounds.width + photoSpacing
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: photoSpacing)
    }
    
    deinit {
        print("deinit")
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for indePath in indexPaths {
//            let data = self.photos[indePath.row]
//            LocalFileImageDataProvider.init(fileURL: URL.init(fileURLWithPath: Bundle.main.path(forResource: data.orginImagePath!, ofType: nil)!))
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        for indePath in indexPaths {
//            let data = self.photos[indePath.row]
//            let cache = ImageCache.default
////            cache.removeImage(forKey: data.orginImagePath!)
//            let key1 = URL.init(fileURLWithPath: Bundle.main.path(forResource: data.orginImagePath!, ofType: nil)!).absoluteString
//            cache.removeImage(forKey: key1)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.photos.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell1 = cell as? FEPhotoOverViewCell
//        cell1?.imageView.image = nil
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEPhotoOverViewCell", for: indexPath) as! FEPhotoOverViewCell
        cell.photo = data
//        cell.imageView.image = nil
//        cell.imageView.image = data.orginImage
//        cell.imageView.kf.cancelDownloadTask()
        let layout =  self.thumbnailView.collectionView.collectionViewLayout as! FEphotoOverviewThumbnailViewFlowLayout
        if (layout.normalLayout) {
            cell.imageView.kf.setImage(with: LocalFileImageDataProvider.init(fileURL: URL.init(fileURLWithPath: Bundle.main.path(forResource: data.middleImagePath!, ofType: nil)!)),
                                       placeholder: nil,
                                       options: [.loadDiskFileSynchronously],
                                       progressBlock: nil,
                                       completionHandler: { (image) in
                                        cell.setNeedsLayout()
            })
        } else {
            weak var tempcell = cell
            cell.imageView.kf.setImage(with: LocalFileImageDataProvider.init(fileURL: URL.init(fileURLWithPath: Bundle.main.path(forResource: data.orginImagePath!, ofType: nil)!)),
                                       placeholder: nil,
                                       options: [.loadDiskFileSynchronously],
                                       progressBlock: nil,
                                       completionHandler: { (image) in
//                                        switch image {
//                                        case .success(let value):
////                                            cell.imageView.image = value.image
//                                            cell.setNeedsLayout()
//                                            break
//                                        case .failure(_):
//                                            print("failure")
//                                            break
//                                        }
                                        tempcell?.setNeedsLayout()
            })
        }
//        }
//        cell.setNeedsLayout()
        
        // 单击
        cell.clickCallback = { _ in
//            self.dismiss()
        }
        // 拖
        cell.panChangedCallback = { [weak self] scale in
//            // 实测用scale的平方，效果比线性好些
//            let alpha = scale * scale
//            self.browser?.transDelegate.maskAlpha = alpha
//            // 半透明时重现状态栏，否则遮盖状态栏
//            self.coverStatusBar(scale > 0.95)
            if (self?.thumbnailView.collectionView.isDecelerating == true) {
                return
            }
            if (self?.transition == nil) {
                self?.transition = FEPhotoOverviewAnimator()
                self?.transition!.operation = UINavigationController.Operation.pop
                self?.transition!.indexPath = indexPath
                self?.transition!.popType = .pan
                self?.navigationController?.popViewController(animated: true)
            }
            self?.transition?.update(scale * scale)
            self?.coverStatusBar(scale > 0.95)
            self?.collectionView.isScrollEnabled = false
          
        }
        // 拖完松手
        cell.panReleasedCallback = { [weak self] isDown in
            if isDown {
                self?.transition?.finish()
            } else {
                self?.collectionView.isScrollEnabled = true
                self?.transition?.cancel()
                self?.transition = nil
                self?.coverStatusBar(true)
            }
        }
        // 长按
        weak var weakCell = cell
        cell.longPressedCallback = { gesture in
//            if let browser = self.browser {
//                self.longPressedCallback?(browser, indexPath.item, weakCell?.imageView.image, gesture)
//            }
        }
        
        // 捏合
        cell.pinchCallback = { [weak self](gesture,scrollView) in
            //判断是否要pop
            self?.canPop(gesture, scrollView, weakCell!,indexPath)
        }
        
        //旋转
        cell.rotateCallback = { [weak self](recognizer) in
            if recognizer.state == .began || recognizer.state == .changed {
                if (self?.transition != nil) {
                    self?.transition?.angle = recognizer.rotation
                }
            }
//            recognizer.rotation = 0
        }
        cell.isPop = { [weak self]() in
            if (self?.transition != nil) {
                return true
            }
            return false
        }
        return cell
    }
    
    func canPop(_ recognizer:FEPhotoIndexPinchGestureRecognizer,_ scrollview: UIScrollView,_ cell: FEPhotoOverViewCell, _ indexPath: IndexPath) {
        if (recognizer.state == .began) {
            if (recognizer.scale < 1) {
                self.transition = FEPhotoOverviewAnimator()
                self.transition!.operation = UINavigationController.Operation.pop
                self.transition!.popType = .pinch
                self.transition!.indexPath = indexPath
                self.lastPoint = recognizer.location(in: self.view)
                self.navigationController?.popViewController(animated: true)
                self.collectionView.isScrollEnabled = false
            } else {
                recognizer.cancelsTouchesInView = true
            }
        } else if(recognizer.state == .changed) {
            if (recognizer.numberOfTouches < 2) {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
            }
            let point = recognizer.location(in: self.view)
            self.transition?.scale = recognizer.scale
            self.transition?.changedPoint = CGPoint.init(x: self.lastPoint.x - point.x, y: self.lastPoint.y - point.y)
            self.transition?.update(1 - recognizer.scale)
            self.lastPoint = point
//            if let view = recognizer.view {
//                let pinchCenter = CGPoint(x: recognizer.location(in: view).x - view.bounds.midX,
//                                          y: recognizer.location(in: view).y - view.bounds.midY)
//                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
//                view.transform = transform
//            }
        } else if (recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed) {
            if (recognizer.scale < 0.95) {
                self.transition?.finish()
            } else {
                cell.resetImageView()
                self.transition?.cancel()
            }
            self.collectionView.isScrollEnabled = true
            self.transition = nil
        }
    }

    /// 遮盖状态栏。以改变windowLevel的方式遮盖
    /// - parameter cover: true-遮盖；false-不遮盖
    open func coverStatusBar(_ cover: Bool) {
        guard isNeedCoverStatusBar else {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        if originWindowLevel == nil {
            originWindowLevel = window.windowLevel
        }
        guard let originLevel = originWindowLevel else {
            return
        }
        window.windowLevel = cover ? .statusBar : originLevel
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
