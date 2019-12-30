//
//  CAGradientLayer.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  ⚠️记得在draw方法中添加layer.frame,因其初始化frame为（0，0，0，0）

import Foundation
import UIKit

extension CAGradientLayer {

    /// 生成水平渐变层（颜色由中间向横向两端渐淡直至透明）
    /// - Parameter centerColor: 中间颜色
    func setHorCenterGradientLayer(centerColor: UIColor) {
        //水平渐变颜色：透明，color，透明
        let gradientsColors = [
            centerColor.withAlphaComponent(0).cgColor,
            centerColor.cgColor,
            centerColor.withAlphaComponent(0).cgColor
        ]
        //位置：起始（透明），中间（color），结束（透明）
        let gradientLocations: [NSNumber] = [0, 0.5, 1]

        colors = gradientsColors
        locations = gradientLocations
        //水平横向；（tips:x<横向>,y<纵向>范围：0～1）
        startPoint = CGPoint(x: 0, y: 0.5)
        endPoint = CGPoint(x: 1, y: 0.5)
    }

    /// 生成对角线渐变层
    /// - Parameter endColor: 末端颜色
    func setCornerGradientLayer(endColor: UIColor) {
        //水平渐变颜色：透明，color，透明
        let gradientsColors = [
            endColor.withAlphaComponent(0).cgColor,
            endColor.cgColor
        ]
        //位置：起始（透明），中间（color），结束（透明）
        let gradientLocations: [NSNumber] = [0, 1]

        colors = gradientsColors
        locations = gradientLocations
        //水平横向；（tips:x<横向>,y<纵向>范围：0～1）
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 1, y: 1)
    }
}
