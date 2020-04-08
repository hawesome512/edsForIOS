//
//  UIButton-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    //Button无效时降低透明度
    override open var isEnabled: Bool {
        didSet {
            backgroundColor = backgroundColor?.withAlphaComponent(isEnabled ? 1 : 0.5)
            //及时更新背景颜色状态的改变
            layoutSubviews()
        }
    }
}
