//
//  FEPhotoOverViewController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FEPhotoOverViewController: UIViewController, FEAnimatorDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    //手势交互
    var transition : FEPhotoOverviewAnimator?
    /// 左右两张图之间的间隙
    open var photoSpacing: CGFloat = 30
    
    var selectedPhoto : FEPhotoCellData?
    
    //原始数据
    var photos : [FEPhotoCellData] = [FEPhotoCellData]()
    
    let thumbnailView = PhotoOverviewThumbnailView()
    let toolBar = PhotoOverviewToolBar()
    
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
        self.thumbnailView.didSelectPhoto = { (p,animated,contact) in
            self.selectedPhoto = p
            self.pageIndex = self.photos.firstIndex(of: p)!
            self.scrollToItem(self.pageIndex, at: .left, animated: animated,contact:contact)
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
        collectionView.reloadData {
            self.collectionView.layoutIfNeeded()
            self.scrollToItem(index, at: .left, animated: false)
            self.collectionView.layoutIfNeeded()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEPhotoOverViewCell", for: indexPath) as! FEPhotoOverViewCell
        cell.imageView.image = data.orginImage
        cell.setNeedsLayout()
        return cell
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
