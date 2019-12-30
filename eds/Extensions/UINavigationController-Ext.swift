//
//  UINavigationViewController-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  默认情况下，若导航栏是父级ViewController，设置子VC的statusBarStyle将无效

import Foundation
import UIKit

extension UINavigationController {

    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
