//
//  FEAnimatorDelegate.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/20.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

@objc public enum FEAnimatorType: Int {
    // spread 3个界面动画
    // detailed 最后去看原图界面的动画
    case spread,detailed
}

@objc public protocol FEAnimatorDelegate {
    @objc func animatorType () -> FEAnimatorType
}
