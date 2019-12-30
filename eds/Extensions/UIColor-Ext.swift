//
//  UIColor-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(colorName: String) {
        var color: UIColor
        switch colorName.lowercased() {
        case "red":
            color = UIColor.systemRed
        case "green":
            color = UIColor.systemGreen
        case "yellow":
            color = UIColor.systemYellow
        default:
            color = UIColor.white
        }
        self.init(cgColor: color.cgColor)
    }
}
