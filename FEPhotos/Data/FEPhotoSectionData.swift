//
//  FEPhotoSectionData.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/18.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FEPhotoSectionData: NSObject {
    var title : String?
    var subTitle : String?
    var photos = [FEPhotoCellData]()
    
    var height : CGFloat! {
        get {
            if let t = self.title, let s = self.subTitle {
                if(t.count > 0 && s.count > 0) {
                    return 60.0
                } else {
                    return 30.0
                }
            } else {
                return 30.0
            }
        }
    }
    //判断photo是否在photos内
    func isPhotoInphotos(photo : FEPhotoCellData!) -> Bool {
        if let a = photos.first, let b = photos.last {
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
            
            var c3 = DateComponents()
            c3.year = photo.year
            c3.month = photo.month
            c3.day = photo.day
            c3.hour = 0
            c3.minute = 0
            c3.second = 0
            c3.calendar = dupCal
            if ((c1.date! <= c3.date!) && (c3.date! <= c2.date!)) {
                return true
            }
        }
        return false
    }
}
