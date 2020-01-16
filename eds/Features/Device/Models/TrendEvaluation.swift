//
//  TrendEvaluation.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//
import Foundation
import UIKit

//运行评估模型：优/良/差
enum TrendEvaluation: String {
    case excellent
    case general
    case bad

    static func initWith(value: Double) -> TrendEvaluation {
        switch value {
        case 0...0.6:
            return .bad
        case 0.6...0.9:
            return .general
        default:
            return .excellent
        }
    }

    func getTotalColor() -> UIColor {
        switch self {
        case .bad:
            return .systemRed
        case .general:
            return .systemYellow
        case .excellent:
            return .systemGreen
        }
    }
    
    //获取评估因素的背景色
    func getItemColor()->UIColor{
        switch self {
        case .bad:
            return .systemRed
        case .general:
            return .systemYellow
        default:
            return .systemGray4
        }
    }
}

//评估因素：波动范围（30%），通讯中断（30%），超值（40%）
//ratio:在许可波动范围内的点占比/通讯值有效点占比/非超值数量占比
enum TrendFactor {
    case stable(ratio: Double)
    case communication(ratio: Double)
    case overflow(ratio: Double)

    func evaluate() -> Double {
        switch self {
        case .stable(let ratio), .communication(let ratio):
            return 0.3 * ratio
        case .overflow(let ratio):
            //只要存在一个超值，就返回0，评估结果为差（100%-40%）bad
            return ratio == 1 ? 0.4 : 0
        }
    }
}
