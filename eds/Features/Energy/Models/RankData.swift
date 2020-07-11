//
//  RankData.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/7/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  用电排行

import Foundation

struct RankData: Comparable {
    
    //用户
    var account = ""
    //综合评分
    var score = 0
    //各时段占比
    var ratios: [Double] = []
    
    /// 平谷分数：平均电价与平段电价对比
    /// - Parameters:
    ///   - energy: <#energy description#>
    ///   - data: <#data description#>
    mutating func setScore(energy: Energy, data: EnergyData?) {
        guard let data = data else { return }
        let total = data.getCurrentTotalValue()
        let timeDatas = EnergyUtility.calTimeDatas(energy: energy, data: data)
        ratios = timeDatas.map{ _ in 1/Double(timeDatas.count) }
        var money: Double = 0
        timeDatas.forEach{ timeData in
            let energyTime = timeData.energyTime
            let index = energyTime.rawValue
            let ratio = total == 0 ? 0 : timeData.totalValue / total
            ratios[index] = ratio
            money += timeData.getMoney()
        }
        let price = money/total
        //用平段为基准，整体评估指数将偏小，改为平峰均值
        let peakPrice = timeDatas.first{ $0.energyTime == .peak }?.price ?? price
        let flatPrice = timeDatas.first{ $0.energyTime == .flat }?.price ?? price
        let standard = (flatPrice+peakPrice)/2
        score = 100 - Int((price - standard)/standard * 100)
    }
    
    static func < (lhs: RankData, rhs: RankData) -> Bool {
        lhs.score < rhs.score
    }
    
    static func == (lhs: RankData, rhs: RankData) -> Bool {
        lhs.score == rhs.score
    }
}
