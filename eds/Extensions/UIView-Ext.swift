//
//  UIView-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    var snapshot: UIImage? {

        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}
