//
//  FEPhotoBaseCollectionController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/19.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

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

class FEPhotoBaseCollectionController: UICollectionViewController {

    //照片显示的类型,每行多少张照片
    var controllerType : FEPhotoControllerType! = .root
    var contentFrame : CGRect = CGRect.zero
    // 点击cell中心相对于window的位置
    var touchCellCenter : CGPoint = CGPoint.zero

    var selectedPhoto : FEPhotoCellData?
    //显示数据
    var datas = [FEPhotoSectionData]()
    
    //原始数据
    var photos : [FEPhotoCellData]? {
        didSet{
            if let array = photos {
                self.buidDatas(photoArray: array)
            }
        }
    }
    
    //滑倒上个界面选择的cell位置,手指的位置
    func scroollToSelectedPhotoInDatas () {
        let (row, section) = self.findSelectedPhotoInDatas() ?? (-1, -1)
        if (row >= 0) {
            let cellLayoutAttributes = self.collectionView.layoutAttributesForItem(at: IndexPath.init(row: row, section: section))
            let center = CGPoint.init(x: cellLayoutAttributes!.frame.midX, y: cellLayoutAttributes!.frame.midY)
            //center.y - self.collectionView.frame.height 将cell放到屏幕的最下方,刚好看见
            //+ (self.contentFrame.size.height - touchCellCenter.y) : 将最下方的cell放到点击的位置
            var offsety = center.y - self.collectionView.frame.height
                + self.contentFrame.size.height - self.touchCellCenter.y
            let maxOffset = self.collectionView.contentSize.height - self.contentFrame.size.height + FECommon.NavBarHeight
            
            //计算sectioheader是否有挡住cell
            //相当于屏幕计算
            let sectioheaderAttributes = self.collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: row, section: section))
            //实际上只有屏幕的第一个header才有可能挡住cell,所以直接从y=0开始
            let screenSectioheaderAttributes = CGRect.init(x: 0, y: 0, width: sectioheaderAttributes!.frame.width, height: sectioheaderAttributes!.frame.height)
            //计算cell相当于屏幕的大小位置
            let screenCellRect = CGRect.init(x: self.touchCellCenter.x - cellLayoutAttributes!.frame.width/2,
                                         y: self.touchCellCenter.y - FECommon.NavBarHeight - cellLayoutAttributes!.frame.height/2,
                                         width: cellLayoutAttributes!.frame.width,
                                         height: cellLayoutAttributes!.frame.height)
            if(screenCellRect.intersects(screenSectioheaderAttributes)){
                let temprect = screenCellRect.intersection(screenSectioheaderAttributes)
                offsety = offsety - temprect.height
            }
//            if (offsety <= -FECommon.NavBarHeight) {
//            if (section == 0 && row < self.controllerType.itemCount()) {
//                offsety = -FECommon.NavBarHeight
//            } else if (offsety >= maxOffset) {
//                offsety = maxOffset
//            }
            if (offsety >= maxOffset) {
                offsety = maxOffset
            }
            self.collectionView.setContentOffset(CGPoint.init(x: 0, y: offsety ), animated: false)
        }
    }
    
    //上个界面选择的photo在这个界面的位置
    func findSelectedPhotoInDatas () -> (Int, Int)?{
        for sectionData in self.datas {
            for photo in sectionData.photos {
                if (photo.id == self.selectedPhoto?.id) {
                    return (sectionData.photos.firstIndex(of: photo)!,self.datas.firstIndex(of: sectionData)!)
                }
            }
        }
        return nil
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

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
