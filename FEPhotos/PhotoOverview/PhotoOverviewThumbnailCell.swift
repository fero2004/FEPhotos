//
//  PhotoOverviewThumbnailCell.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/7/19.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class PhotoOverviewThumbnailCell: UICollectionViewCell {
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        attributes.frame.size.width = 122
//        attributes.frame.size.height = 44
//        imageView.frame = CGRect.init(x: 0, y: 0, width: attributes.frame.size.width, height: attributes.frame.size.height)
//        return attributes
//    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        imageView.frame = CGRect.init(x: 0, y: 0, width: layoutAttributes.frame.width, height: layoutAttributes.frame.height)
    }
    /// ImageView
    open var imageView = UIImageView()
    
    /// 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
