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
        self.contentFrame = self.collectionView.frame
        
//        self.collectionView.setNeedsLayout()
//        self.collectionView.layoutIfNeeded()
//        DispatchQueue.main.async {
//            self.scroollToSelectedPhotoInDatas()
//        }
//        self.collectionView.reloadData(){
//        self.scroollToSelectedPhotoInDatas()
//        }
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
            header.titleLabel.text = String.init(format: "%d", indexPath.section)
            return header
        }
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionData = self.datas[indexPath.section]
        let photoData = sectionData.photos[indexPath.row]
//        
//        let cell = collectionView.cellForItem(at: indexPath)
//        //相对于window的位置
//        let rect = cell?.convert(cell!.bounds, to: UIApplication.shared.keyWindow)
//        let center = CGPoint.init(x: rect!.midX, y: rect!.midY)
        
//        let view = UIView()
//        view.backgroundColor = UIColor.red
//        view.frame = CGRect.init(x: 0, y: 0, width: 10, height: 10)
//        view.center = CGPoint.init(x: center.x, y: center.y - FECommon.NavBarHeight)//center
//        self.collectionView.addSubview(view)
        
        self.selectedPhoto = photoData
        let con = FEPhotoCollectionController.init(nibName: "FEPhotoCollectionController", bundle: nil)
//        con.touchCellCenter = center
        con.controllerType = self.controllerType == .root ? .step : .detail
        con.photos = self.photos
        con.selectedPhoto = photoData
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
