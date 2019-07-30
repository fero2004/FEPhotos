//
//  Common.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/17.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FECommon: NSObject {
//    static let NavBarHeight : CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top + 44.0
    static let TabBarHeight : CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 49.0
    
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
        for i in 1...154 {
            let data = FEPhotoCellData()
            let y = year.randomElement()
            let m = month.randomElement()
            let d = day.randomElement()
            let image = String(i) + ".jpg"
            let smallimage = "small_" + String(i) + ".jpg"
            
            data.year = y
            data.month = m
            data.day = d
            data.smallImagePath = smallimage
            data.middleImagePath = image
            data.bigImagePath = image
            data.orginImagePath = image
            data.address = address.randomElement()
            photos.append(data)
        }
        //排序
        photos.sort(by: { (a,b) in
            var c1 = DateComponents()
            let dupCal = Calendar.current
            c1.year = a.year
            c1.month = a.month
            c1.day = a.day
            c1.hour = 0
            c1.minute = 0
            c1.second = 0
            c1.calendar = dupCal
            
            var c2 = DateComponents()
            c2.year = b.year
            c2.month = b.month
            c2.day = b.day
            c2.hour = 0
            c2.minute = 0
            c2.second = 0
            c2.calendar = dupCal
            
            return c1.date! < c2.date!
        })
        return photos
    }
}
