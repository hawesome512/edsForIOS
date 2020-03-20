//
//  PhotoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    let contentImage = UIImageView()

    private func initViews() {
        contentImage.clipsToBounds = true
        contentImage.contentMode = .scaleAspectFill
        //设置tineColor，默认图片颜色
        contentImage.tintColor = edsLightGrayColor
        contentImage.layer.borderColor = edsLightGrayColor.cgColor
        contentImage.layer.borderWidth = 1
//        contentImage.image = UIImage(named: "device_A1")
        addSubview(contentImage)
        contentImage.edgesToSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
