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
    
    var didSelectPhoto : ((FEPhotoCellData,Bool,Bool) -> ())?
    
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
 
        self.flowLayout.currect = currect
        self.flowLayout.currectPersent = currectPersent
        self.flowLayout.next = next
        self.flowLayout.nextPersent = nextPersent
        if (self.collectionView.isDragging) {
            return
        }
        self.flowLayout.normalLayout = false
        var x : CGFloat = 0.0
        let width = self.flowLayout.itemSize.width
        for _ in 0...self.photos.firstIndex(of: currect)! {
            x = x + width + self.flowLayout.minimumInteritemSpacing
        }
        let addWidth = (self.flowLayout.itemSize.width + self.flowLayout.minimumInteritemSpacing) * (1.0 - currectPersent)
        let value : CGFloat = (x - width - self.flowLayout.minimumInteritemSpacing) + addWidth - collectionView.contentInset.left
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: self.frame.width/2 - flowLayout.itemSize.width / 2, bottom: 0, right: self.frame.width/2 - flowLayout.itemSize.width / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let data = self.photos[indexPath.row]
//        let photo = self.selectedPhoto!
//        let fitSize = CGSize.init(width: photo.orginImage!.size.width, height: photo.orginImage!.size.height)
//        let pesent_1_Width : CGFloat = self.flowLayout.itemSize.height / (fitSize.height / fitSize.width)
//        if (photo == data) {
//            return CGSize.init(width: pesent_1_Width, height: self.frame.height)
//        } else {
//            return CGSize.init(width: self.frame.height / 2, height: self.frame.height)
//        }
//    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.photos[indexPath.row]
        if (self.didSelectPhoto != nil && data != self.selectedPhoto) {
            self.didSelectPhoto!(data,true,false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.flowLayout.normalLayout = true
        self.collectionView.performBatchUpdates({
            self.flowLayout.invalidateLayout()
        }) { (b) in
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.flowLayout.normalLayout = false
        self.collectionView.performBatchUpdates({
            self.flowLayout.invalidateLayout()
        }) { (b) in
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.collectionView.isDragging) {
            let indexPathsForVisibleItems = self.collectionView.indexPathsForVisibleItems
            let centerx = scrollView.contentOffset.x + scrollView.frame.width / 2
            for l in indexPathsForVisibleItems {
                if let attr = self.collectionView.layoutAttributesForItem(at: l), let cell = self.collectionView.cellForItem(at: l) {
                    //不能用attr.frame来判断,不准,原因不明
                    if(cell.frame.contains(CGPoint.init(x: centerx, y: self.frame.height / 2))){
                        let p = self.photos[attr.indexPath.row]
                        if (self.didSelectPhoto != nil) {
                            self.didSelectPhoto!(p,false,false)
                        }
                        break
                    }
                }
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
