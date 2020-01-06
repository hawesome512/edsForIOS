//
//  Double-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/31.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation

extension Double {

    /// 转换为String，整数时不带小数部分
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
