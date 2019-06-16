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
    var controllerType : FEPhotoControllerType!
//    var offsetScale : CGFloat = 0.0
//    var offsetHeight : CGFloat = 0.0
    var touchCellCenter : CGPoint = CGPoint.zero
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
//self.collectionView.isPagingEnabled = true
        self.collectionView.alwaysBounceVertical = true
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "FEPhotoCell", bundle: nil), forCellWithReuseIdentifier: "FEPhotoCell")

        self.collectionView.register(UINib.init(nibName: "FEPhotoSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FEPhotoSectionHeaderView")
       
        self.collectionView.layoutIfNeeded()
        self.collectionView.setContentOffset(CGPoint.init(x: 0, y: 725.0), animated: false)
//        let height = self.collectionView.frame.height - 88 - 83
//        let scale = touchCellCenter.y / height
//
//        let offset = (self.collectionView.contentSize.height - 88 - 83) * scale
//        var contentoffsety = offset - touchCellCenter.y - 88
//
//        if (contentoffsety <= 0) {
//            contentoffsety = 0
//        }
//
//        self.collectionView.setContentOffset(CGPoint.init(x: 0, y: contentoffsety), animated: false)
             // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 480
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FEPhotoCell", for: indexPath) as! FEPhotoCell
        cell.backgroundColor = Color.random
        // Configure the cell
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
        //相对于collectionView的位置
        let rect = cell?.convert(cell!.bounds, to: collectionView)
        let center = CGPoint.init(x: rect!.midX, y: rect!.midY)
        
//        let offsetScale = cell!.frame.midY / collectionView.contentSize.height

        let con = FEPhotoCollectionController.init(nibName: "FEPhotoCollectionController", bundle: nil)
        con.touchCellCenter = center
//        con.offsetHeight = center.y
//        con.offsetScale = offsetScale
        con.controllerType = .step
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
