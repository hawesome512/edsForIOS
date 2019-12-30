//
//  DeviceHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  设备页头图

import UIKit
import TinyConstraints

class DeviceHeaderView: UIView {

    private let cornerGradientLayer = CAGradientLayer()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        //添加渐变层
        cornerGradientLayer.setCornerGradientLayer(endColor: edsDefaultColor)
        layer.insertSublayer(cornerGradientLayer, at: 0)
        //默认View为黑色
        backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.edgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //渐变层需要约束frame
        cornerGradientLayer.frame = rect
    }

}
