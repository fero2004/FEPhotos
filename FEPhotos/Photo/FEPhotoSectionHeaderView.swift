//
//  FEPhotoSectionHeaderView.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/16.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FEPhotoSectionHeaderView: UICollectionReusableView {
   
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var subTitleLabel : UILabel!
    @IBOutlet var titleLabel0 : UILabel! {
        didSet {
            titleLabel0.isHidden = true
        }
    }
    //        初始化一个模糊效果对象（可以制作毛玻璃效果）
    let blur = UIBlurEffect(style: .extraLight)
    var blurView : UIVisualEffectView?
    var data : FEPhotoSectionData? {
        didSet {
            self.titleLabel.isHidden = true
            self.subTitleLabel.isHidden  = true
            self.titleLabel0.isHidden = true
            if let d = data {
                if let t = d.title, let s = d.subTitle {
                    if(t.count > 0 && s.count > 0) {
                        self.titleLabel.isHidden = false
                        self.subTitleLabel.isHidden  = false
                        self.titleLabel.text = t
                        self.subTitleLabel.text = s
                    } else {
                        self.titleLabel0.isHidden = false
                        self.titleLabel0.text = t
                    }
                } else {
                    self.titleLabel0.isHidden = false
                    self.titleLabel0.text = (d.title != nil && d.title!.count > 0) ? d.title : ""
                }
            }
        }
    }
    
    var isBlur : Bool? {
        didSet {
            if (isBlur ?? false) {
                self.blurView?.removeFromSuperview()
                self.blurView = nil
                let blurView = UIVisualEffectView(effect: self.blur)
                blurView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
//                blurView.layer.masksToBounds = true
                self.insertSubview(blurView, belowSubview: self.titleLabel)
                self.blurView = blurView
            } else {
                self.blurView?.removeFromSuperview()
                self.blurView = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
