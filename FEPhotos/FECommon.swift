//
//  Common.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/17.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit
import Kingfisher

class FECommon: NSObject {
//    static let NavBarHeight : CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top + 44.0
    static let TabBarHeight : CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 49.0
    
    static func getLocalFileImageDataProvider(_ path: String) -> LocalFileImageDataProvider {
        return LocalFileImageDataProvider.init(fileURL: URL.init(fileURLWithPath: Bundle.main.path(forResource: path, ofType: nil)!))
    }
    
    static func buildData() -> [FEPhotoCellData] {
        let year = [2019,2018,2017]
        let month = [1,2,3,4,5,6,7,8,9,10,11,12]
        var day = [Int]()
        let address = ["四川省","广东省",""]
        //直接全部26天..
        for i in 1...26 {
            day.append(i)
        }
        var photos = [FEPhotoCellData]()
        for _ in 1...6 {
            for i in 1...1084 {
                let data = FEPhotoCellData()
                let y = year.randomElement()
                let m = month.randomElement()
                let d = day.randomElement()
                let smallimage = "small_" + String(i) + ".jpg"
                let middleimage = "middle_" + String(i) + ".jpg"
                let bigimage = "big_" + String(i) + ".jpg"
                let orginimage = "orgin_" + String(i) + ".jpg"
                data.year = y
                data.month = m
                data.day = d
                data.smallImagePath = smallimage
                data.middleImagePath = middleimage
                data.bigImagePath = bigimage
                data.orginImagePath = orginimage
                let _ = data.orginImageSize //提前加载好大小
                data.address = address.randomElement()
                photos.append(data)
            }
        }
        //排序
        photos.sort(by: { (a,b) in
//            var c1 = DateComponents()
//            let dupCal = Calendar.current
//            c1.year = a.year
//            c1.month = a.month
//            c1.day = a.day
//            c1.hour = 0
//            c1.minute = 0
//            c1.second = 0
//            c1.calendar = dupCal
//
//            var c2 = DateComponents()
//            c2.year = b.year
//            c2.month = b.month
//            c2.day = b.day
//            c2.hour = 0
//            c2.minute = 0
//            c2.second = 0
//            c2.calendar = dupCal
//
//            return c1.date! < c2.date!
            // 必须加autoreleasepool,要不内存会爆炸
            // 这里排序很慢
            var c : Bool = false
            autoreleasepool { () in
                let date1 = Date(year: a.year, month: a.month, day: a.day)
                let date2 = Date(year: b.year, month: b.month, day: b.day)
                c = date1!.timeIntervalSince1970 < date2!.timeIntervalSince1970
            }
            return c
        })
        return photos
    }
    
    static func buildData(callBack : ((_ photos: [FEPhotoCellData]) -> Void)?) {
        DispatchQueue.global(qos: .`default`).async {
            let photos = FECommon.buildData()
            DispatchQueue.main.async {
                if (callBack != nil) {
                    callBack!(photos)
                }
            }
        }
    }
    
    static func clearCache() {
        let cache = ImageCache.default
        // 清除
        cache.clearDiskCache()
        cache.clearMemoryCache()
        
        cache.clearDiskCache {
        }
        // 清除过期缓存
        cache.cleanExpiredDiskCache()
        cache.cleanExpiredDiskCache {
        }
        cache.backgroundCleanExpiredDiskCache()// 后台清理，但不需要回调
    }
    
    static func initWindow(navDelegate: FENavigationControllerDelegate,window: UIWindow?) {
        let cache = ImageCache.default
        // 设置内存缓存的大小，默认是0 pixel表示no limit ，注意它是像素为单位，与我们平时的bytes不同
        cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
        // 磁盘缓存大小，默认0 bytes表示no limit （50 * 1024）
        cache.diskStorage.config.sizeLimit = 10 * 1024 * 1024
        
        window?.rootViewController = FELoadingViewController()
        FECommon.buildData { (photos) in
            let tab = FEBaseTabBarViewController()
            let photo = FEPhotoCollectionController(nibName: "FEPhotoCollectionController", bundle: nil)
            photo.controllerType = .root
            photo.photos = photos
            let nav = FEBaseNavigationController.init(rootViewController: photo)
            nav.delegate = navDelegate
            tab.viewControllers = [nav]
            window?.rootViewController = tab
        }
    }
}
