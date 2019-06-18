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
    //小图
    var smallImage : UIImage?
    //中图
    var middleImage : UIImage?
    //大图
    var bigImage : UIImage?
    //原图
    var orginImage : UIImage?
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
