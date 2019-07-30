//
//  PhotoOverviewThumbnailView.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/19.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import SnapKit

class PhotoOverviewThumbnailView: UIView, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    var selectedPhoto : FEPhotoCellData?
    
    var startX : Double = 0.0
    
//    var overViewScrollViewPreOffsetX : CGFloat = 0.0
//
//    var overViewScrollViewNextOffsetX : CGFloat = 444.0
    
    //原始数据
    var photos : [FEPhotoCellData] = [FEPhotoCellData]()
    
    /// 流型布局
    open lazy var flowLayout: FEphotoOverviewThumbnailViewFlowLayout = {
        let layout = FEphotoOverviewThumbnailViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    /// 容器
    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
//        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.isPagingEnabled = true
//        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        collectionView.dataSource = self;
        return collectionView
    }()
    
    func overViewScrollViewDidScroll(_ scrollView: UIScrollView, currect : FEPhotoCellData, currectPersent : CGFloat,next : FEPhotoCellData? ,nextPersent : CGFloat) {
        
        var x : CGFloat = 0.0
        let width = self.flowLayout.itemSize.width
        for _ in 0...self.photos.firstIndex(of: currect)! {
            x = x + width + self.flowLayout.minimumInteritemSpacing
        }
        let addWidth = (self.flowLayout.itemSize.width + self.flowLayout.minimumInteritemSpacing) * (1.0 - currectPersent)
        let value : CGFloat = (x - width - self.flowLayout.minimumInteritemSpacing) + addWidth - collectionView.contentInset.left
        
        self.flowLayout.currect = currect
        self.flowLayout.currectPersent = currectPersent
        self.flowLayout.next = next
        self.flowLayout.nextPersent = nextPersent
        
        self.collectionView.setContentOffset(CGPoint.init(x: value, y: 0), animated: false)
        self.collectionView.bounds = CGRect.init(x: value,
                                                 y: 0,
                                                 width:self.collectionView.bounds.size.width,
                                                 height: self.collectionView.bounds.size.height)
        self.flowLayout.invalidateLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(PhotoOverviewThumbnailCell.self, forCellWithReuseIdentifier: "PhotoOverviewThumbnailCell")
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero);
        }
    }
    
    private func setLayout() {
        flowLayout.photos = self.photos
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.itemSize = CGSize.init(width: self.frame.height / 2, height: self.frame.height)
//        flowLayout.estimatedItemSize = CGSize.init(width: 10, height: 10)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: self.frame.width/2 - flowLayout.itemSize.width / 2, bottom: 0, right: 0)
//        collectionView.bounds = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.startX = collectionView.contentOffset.x.double
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoOverviewThumbnailCell", for: indexPath) as! PhotoOverviewThumbnailCell
        cell.imageView.image = data.smallImage
        cell.setNeedsLayout()
        return cell
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
