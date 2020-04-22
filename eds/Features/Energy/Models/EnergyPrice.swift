//
//  EnergyPriceMode.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  分时用电统计

import Foundation

enum EnergyPrice {
    //低谷，电费50%
    case valley
    //平段
    case plain
    //高峰，电费150%
    case peek

    init(hourOfDay: Int) {
        //各8h
        switch hourOfDay {
        case 7..<8, 11..<18:
            self = .plain
        case 8..<11, 18..<23:
            self = .peek
        default:
            self = .valley
        }
    }

    func getPrice(_ basicPrice: Double = 0.8) -> Double {
        switch self {
        case .valley:
            return basicPrice * 0.5
        case .plain:
            return basicPrice
        case .peek:
            return basicPrice * 1.5
        }
    }
}
