//
//  FEPhotoCollectionController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import SwifterSwift

enum FEPhotoControllerType {
    case root, step, detail
    func itemCount() -> Int {
        switch self {
        case .root:
            return 32
        case .step:
            return 10
        case .detail:
            return 4
        }
    }
}

class FEPhotoCollectionController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    //照片显示的类型,每行多少张照片
    var controllerType : FEPhotoControllerType! = .root

    var contentFrame : CGRect = CGRect.zero
    // 点击cell中心相对于contentFrame的位置
    var touchCellCenter : CGPoint = CGPoint.zero
    //原始数据
    var photos : [FEPhotoCellData]? {
        didSet{
            if let array = photos {
                self.buidDatas(photoArray: array)
            }
        }
    }
    //显示数据
    var datas = [FEPhotoSectionData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.white
        let width = self.collectionView.frame.width / CGFloat(self.controllerType.itemCount())

        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = CGSize(width: width,height: width)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.collectionView.alwaysBounceVertical = true
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "FEPhotoCell", bundle: nil), forCellWithReuseIdentifier: "FEPhotoCell")

        self.collectionView.register(UINib.init(nibName: "FEPhotoSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FEPhotoSectionHeaderView")
        //        self.contentFrame = CGRect.init(x: 0,
        //                                        y: 0,
        //                                        width: self.collectionView.frame.width,
        //                                        height: self.collectionView.frame.height - FECommon.NavBarHeight - FECommon.TabBarHeight)
        self.contentFrame = self.collectionView.frame
        
        self.collectionView.layoutIfNeeded()
        self.collectionView.reloadData(){
            if (self.controllerType != .root) {
                // 测试代码,找到选择的cell
                let cellLayoutAttributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(row: 0, section: 3))
                let center = CGPoint.init(x: cellLayoutAttributes!.frame.midX, y: cellLayoutAttributes!.frame.midY)
                //center.y - self.collectionView.frame.height 将cell放到屏幕的最下方,刚好看见
                //+ (self.contentFrame.size.height - touchCellCenter.y) : 将最下方的cell放到点击的位置
                var offsety = center.y - self.collectionView.frame.height
                    + self.contentFrame.size.height - self.touchCellCenter.y
                if (offsety <= 0) {
                    offsety = 0
                } else if (offsety - self.contentFrame.size.height >= self.collectionView.contentSize.height) {
                    offsety = self.collectionView.contentSize.height - self.contentFrame.size.height
                }
                self.collectionView.setContentOffset(CGPoint.init(x: 0, y: offsety ), animated: false)
            }
        }
    }
    
    func checkItemIsEqual(a: FEPhotoCellData!, b: FEPhotoCellData!) -> Bool {
        switch self.controllerType {
        case .root:
            if (a.year == b.year) {
                return true
            }
            break
        case .step:
            if (a.month == b.month) {
                return true
            }
            break
        case .detail:
            if (a.day == b.day) {
                return true
            }
            break;
        default:
            break
        }
        return false
    }
    
    func buidDatas (photoArray : [FEPhotoCellData]!) {
        if (photoArray.count > 0) {
            var sectionData = FEPhotoSectionData()
            sectionData.photos.append(photoArray[0])
            self.datas.append(sectionData)
            for i in 1..<photoArray.count {
                let item = photoArray[i]
                if let lastItem = sectionData.photos.last {
                    if (self.checkItemIsEqual(a: item, b: lastItem)) {
                        sectionData.photos.append(item)
                    } else {
                        sectionData = FEPhotoSectionData()
                        sectionData.photos.append(item)
                        self.datas.append(sectionData)
                    }
                } else {
                    sectionData.photos.append(item)
                }
            }
        }
        switch self.controllerType {
        case .root:
            self.buildRootDatasTitle()
            break
        case .step:
            self.buidStepDatasTitle()
            break
        case .detail:
            self.buidDetailDatasTitle()
            break;
        default:
            break
        }
    }
    
    func buildRootDatasTitle () {
        for sectionData in self.datas {
            if (sectionData.photos.count > 0) {
                sectionData.title = String(sectionData.photos[0].year!)
                var subtitles = [String]()
                for photo in sectionData.photos {
                    if (photo.address!.count > 0 && !subtitles.contains(photo.address!)) {
                        subtitles.append(photo.address!)
                    }
                }
                if (subtitles.count > 0) {
                    sectionData.subTitle = subtitles.joined(separator: ",")
                }
            }
        }
    }
    
    func buidStepDatasTitle () {
        for sectionData in self.datas {
            var titles = [String]()
            for photo in sectionData.photos {
                if (photo.address!.count > 0 && !titles.contains(photo.address!)) {
                    titles.append(photo.address!)
                }
            }
            var subtitle = ""
            if (sectionData.photos.count >= 2) {
                if let first = sectionData.photos.first , let last = sectionData.photos.last {
                    subtitle.append(String(first.year!) + "年" + String(first.month!) + "月" + String(first.day!) + "日")
                    subtitle.append("至" + String(last.day!) + "日")
                }
            }
            else if (sectionData.photos.count == 1) {
                if let first = sectionData.photos.first {
                    subtitle.append(String(first.year!) + "年" + String(first.month!) + "月" + String(first.day!) + "日")
                }
            }
            if (titles.count > 0) {
                sectionData.title = titles.joined(separator: " - ")
                if (subtitle.count > 0) {
                    sectionData.subTitle = subtitle
                }
            } else {
                if (subtitle.count > 0) {
                    sectionData.title = subtitle
                }
            }
        }
    }
    
    func buidDetailDatasTitle () {
        for sectionData in self.datas {
            if let first = sectionData.photos.first {
                sectionData.title = (String(first.year!) + "年" + String(first.month!) + "月" + String(first.day!) + "日")
            }
        }
    }
    
    override func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.datas.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = self.datas[section]
        return sectionData.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEPhotoCell", for: indexPath) as! FEPhotoCell
        let sectionData = self.datas[indexPath.section]
        let photoData = sectionData.photos[indexPath.row]
        cell.imageView.image = photoData.smallImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FEPhotoSectionHeaderView", for: indexPath) as! FEPhotoSectionHeaderView
            header.titleLabel.text = "1"
            return header
        }
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        //相对于window的位置
        let rect = cell?.convert(cell!.bounds, to: UIApplication.shared.keyWindow)
        let center = CGPoint.init(x: rect!.midX, y: rect!.midY)
        
        let con = FEPhotoCollectionController.init(nibName: "FEPhotoCollectionController", bundle: nil)
        con.touchCellCenter = center
        con.controllerType = self.controllerType == .root ? .step : .detail
        self.navigationController?.pushViewController(con, animated: true)
    }
    
//    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//    {
//        return CGSize(width: 100, height: 100)
//    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
