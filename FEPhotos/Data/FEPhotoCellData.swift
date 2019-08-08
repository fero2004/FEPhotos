//
//  FEPhotoCellData.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/17.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

enum FEPhotoCellDataType {
    case image, video
}

class FEPhotoCellData: NSObject {
    //唯一id,这里测试用,直接给一个值
    let id = UUID().uuidString
    //类型
    var type : FEPhotoCellDataType = .image
    
    var smallImagePath : String?
    var middleImagePath : String?
    var bigImagePath : String?
    var orginImagePath : String?
    //小图
    var smallImage : UIImage?{
        get{
            let path = Bundle.main.path(forResource: self.smallImagePath!, ofType: nil)
            return UIImage.init(contentsOfFile: path!)
            //不能使用,会cache在内存,会爆炸
//            return UIImage.init(named: self.smallImagePath!)
        }
    }
    //中图
    var middleImage : UIImage?{
        get{
            let path = Bundle.main.path(forResource: self.middleImagePath!, ofType: nil)
            return UIImage.init(contentsOfFile: path!)
//            return UIImage.init(named: self.middleImagePath!)
        }
    }
    //大图
    var bigImage : UIImage?{
        get{
            let path = Bundle.main.path(forResource: self.bigImagePath!, ofType: nil)
            return UIImage.init(contentsOfFile: path!)
//            return UIImage.init(named: self.bigImagePath!)
        }
    }
    //原图
    var orginImage : UIImage?{
        get{
            let path = Bundle.main.path(forResource: self.orginImagePath!, ofType: nil)
            return UIImage.init(contentsOfFile: path!)
//            return UIImage.init(named: self.orginImagePath!)
        }
    }
    
    open lazy var orginImageSize: CGSize = {
         var size = CGSize.zero
         size = self.orginImage?.size ?? .zero
         return size
    }()
    
    //年份
    var year : Int?
    //月份
    var month : Int?
    //日
    var day : Int?
    //地址
    var address : String?
    //来源,video使用
    var source : String?
}
