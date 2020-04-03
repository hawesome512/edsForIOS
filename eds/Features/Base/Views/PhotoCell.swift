//
//  PhotoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {

    let deleteButton = UIButton()
    let contentImage = UIImageView()
    let indexLabel = RoundLabel()

    var url: URL? {
        didSet {
            contentImage.kf.setImage(with: url)
//            contentImage.kf.setImage(with: url, placeholder: edsDefaultImage)
        }
    }

    private func initViews() {
        contentImage.clipsToBounds = true
        contentImage.contentMode = .scaleAspectFit
        //加载动画
        contentImage.kf.indicatorType = .activity
        //设置tineColor，默认图片颜色
        contentImage.tintColor = edsLightGrayColor
//        contentImage.image = UIImage(systemName: "plus")
        addSubview(contentImage)
        contentImage.edgesToSuperview()

        indexLabel.backgroundColor = edsLightGrayColor.withAlphaComponent(0.5)
        addSubview(indexLabel)
        indexLabel.centerXToSuperview()
        indexLabel.bottomToSuperview(offset: -edsSpace)

        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(deleteButton)
        deleteButton.height(edsIconSize)
        deleteButton.width(edsIconSize)
        deleteButton.topToSuperview(offset: 0)
        deleteButton.trailingToSuperview(offset: 0)
        deleteButton.alpha = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setBorder() {
        contentImage.layer.borderColor = edsLightGrayColor.cgColor
        contentImage.layer.borderWidth = 1
        contentImage.contentMode = .scaleAspectFill
    }


}
