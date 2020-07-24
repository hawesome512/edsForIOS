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

    func roundToPlaces(fractions: Int = 1) -> Double {
        let divisor = pow(10.0, Double(fractions))
        return (self * divisor).rounded() / divisor
    }
    
    func autoRounded() -> Double {
        var fractions = 0
        switch abs(self) {
        case 0...1:
            return self
        case 1..<10:
            fractions = 2
        case 10..<100:
            fractions = 1
        default:
            fractions = 0
        }
        let divisor = pow(10.0, Double(fractions))
        return (self * divisor).rounded() / divisor
    }
    
    /// 货币格式
    /// - Parameter fractions: 小数位数
    /// - Returns: <#description#>
    func toCurrencyValue(fractions: Int = 0) -> String? {
        let number = NSNumber(value: self)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = fractions
        formatter.numberStyle = .currency
        return formatter.string(from: number)
    }
}
