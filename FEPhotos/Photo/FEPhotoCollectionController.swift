//
//  FEPhotoCollectionController.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import SwifterSwift

class FEPhotoCollectionController: FEPhotoBaseCollectionController,UICollectionViewDelegateFlowLayout,FEAnimatorDelegate {
    
    func animatorType() -> FEAnimatorType {
        return .spread
    }
    var isDidAppear = false
    var longPressImageView : UIImageView? //长按出现的iamgeview
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectedPhotoChanged(_:)),
        name: NSNotification.Name(rawValue: "selectedPhotoChanged"),
        object: nil)
        
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
        self.contentFrame = self.collectionView.frame
        
//        let backItem = UIBarButtonItem.init(title: "", style: .done, target: self, action: #selector(back))
//        self.navigationItem.backBarButtonItem = backItem

        if (self.navigationController?.viewControllers.count ?? 0 > 1) {
            let backToRootVCButton = UIBarButtonItem.init(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
            self.navigationItem.setLeftBarButton(backToRootVCButton, animated: true)
        }
//        self.collectionView.canCancelContentTouches = false
//        self.collectionView.isMultipleTouchEnabled = false
//        self.navigationItem.leftItemsSupplementBackButton = true
        
        let lonpress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        lonpress.minimumPressDuration = 0.5
        lonpress.delaysTouchesBegan = true
        self.view.addGestureRecognizer(lonpress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer)  {
        self.longPressImageView?.removeFromSuperview()
        self.longPressImageView = nil
        if (gesture.state == .ended || gesture.state == .cancelled) {
            return
        }
        let location = gesture.location(in: self.collectionView)
        print(location)
        if let indexPath = self.collectionView.indexPathForItem(at: location) {
            let sectionData = self.datas[indexPath.section]
            let photoData = sectionData.photos[indexPath.row]

            self.longPressImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 65, height: 65))
            self.longPressImageView?.center = CGPoint.init(x: location.x, y: location.y - self.collectionView.contentOffset.y - 55)
            self.longPressImageView?.image = photoData.bigImage
            self.longPressImageView?.contentMode = .scaleAspectFill
            self.longPressImageView?.clipsToBounds = true
            UIApplication.shared.keyWindow?.addSubview(self.longPressImageView!)
        }
    }
    
    @objc private func back() {
        let (row,section) = self.findSelectedPhotoInDatas() ?? (-1 , -1)
        if (row >= 0) {
            let indexPath = IndexPath.init(row: row, section: section)
            let cell = self.collectionView.cellForItem(at: indexPath)
            if cell == nil {
                //没有找到,重新设置selecteddata,取屏幕中间的数据
                let indexPathsForVisibleCells = self.collectionView.indexPathsForVisibleItems
                let indexPaths = indexPathsForVisibleCells.sorted(by: { (a,b) -> Bool in
                    return a.compare(b) == .orderedAscending
                })
                if (indexPaths.count > 0) {
                    let index = indexPaths.count / 2
                    let indexPath = indexPaths[index]
                    let sectionData = self.datas[indexPath.section]
                    let photoData = sectionData.photos[indexPath.row]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectedPhotoChanged"),
                                                    object: photoData)
                }
            } else {
                
            }
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectedPhotoChanged(_ noti: Notification) {
        let data = noti.object as! FEPhotoCellData
        self.selectedPhoto = data
    }
    
    override func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isDidAppear = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isDidAppear = false
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
    
    func checkHeaderViewBlur(indexPath : IndexPath) {
        UIView.animate(withDuration: 0, delay: 0, animations: {
            
        }) { [weak self](b) in
            //不能直接collectionView.supplementaryView,刚进界面的时候会没有值,这里用UIView.animate
            if let header = self?.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? FEPhotoSectionHeaderView {
                if (self?.collectionView.headerIsPinnedOrUnderContentInsetTop(section: indexPath.section) ?? false) {
                    header.isBlur = true
                } else {
                    header.isBlur = false
                }
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self != self.navigationController?.viewControllers.last){
            return
        }
        if (self.isDidAppear) {
            for indexPath in self.collectionView?.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader) ?? [] {
                self.checkHeaderViewBlur(indexPath: indexPath)
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.datas.count
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let sectionData = self.datas[indexPath.section]
//        let photoData = sectionData.photos[indexPath.row]
//        if (photoData.id == self.selectedPhoto?.id && self.isDidAppear) {
//            //没有找到,重新设置selecteddata,取屏幕中间的数据
//            let indexPathsForVisibleCells = self.collectionView.indexPathsForVisibleItems
//            let indexPaths = indexPathsForVisibleCells.sorted(by: { (a,b) -> Bool in
//                return a.compare(b) == .orderedAscending
//            })
//            if (indexPaths.count > 0) {
//                let index = indexPaths.count / 2
//                let indexPath1 = indexPaths[index]
//                let sectionData1 = self.datas[indexPath1.section]
//                let photoData1 = sectionData1.photos[indexPath1.row]
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectedPhotoChanged"),
//                                                object: photoData1)
//            }
//        } else {
//
//        }
//    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = self.datas[section]
        return sectionData.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEPhotoCell", for: indexPath) as! FEPhotoCell
        let sectionData = self.datas[indexPath.section]
        let photoData = sectionData.photos[indexPath.row]
        switch self.controllerType {
        case .root:
            cell.imageView.image = photoData.smallImage
            break
        case .step:
            cell.imageView.image = photoData.middleImage
            break
        case .detail:
            cell.imageView.image = photoData.bigImage
            break
        default:
            break
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FEPhotoSectionHeaderView", for: indexPath) as! FEPhotoSectionHeaderView
            let sectionData = self.datas[indexPath.section]
            header.data = sectionData
            self.checkHeaderViewBlur(indexPath: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        let sectionData = self.datas[section]
        return CGSize(width: collectionView.frame.width, height: sectionData.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionData = self.datas[indexPath.section]
        let photoData = sectionData.photos[indexPath.row]
        
        self.selectedPhoto = photoData
        if(self.controllerType != .detail) {
            let con = FEPhotoCollectionController.init(nibName: "FEPhotoCollectionController", bundle: nil)
            con.controllerType = self.controllerType == .root ? .step : .detail
            con.photos = self.photos
            con.selectedPhoto = photoData
            self.navigationController?.pushViewController(con, animated: true)
        } else {
            let con = FEPhotoOverViewController.init(nibName: "FEPhotoOverViewController", bundle: nil)
            con.selectedPhoto = self.selectedPhoto
            con.photos = self.photos ?? []
//            con.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(con, animated: true)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectedPhotoChanged"),
                                        object: photoData)
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
