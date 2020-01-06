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

    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
        let f = min(1, max(0, fraction))
        let c1 = from.components()
        let c2 = to.components()
        let r = c1.0 + (c2.0 - c1.0) * f
        let g = c1.1 + (c2.1 - c1.1) * f
        let b = c1.2 + (c2.2 - c1.2) * f
        let a = c1.3 + (c2.3 - c1.3) * f
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    func components() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let c = cgColor.components else { return (0, 0, 0, 1) }
        if (cgColor.numberOfComponents == 2) {
            return (c[0], c[0], c[0], c[1])
        } else {
            return (c[0], c[1], c[2], c[3])
        }
    }
}
