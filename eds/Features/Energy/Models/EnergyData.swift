//
//  File.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  能耗查询数据转换模型

import Foundation

struct EnergyData {
    //上一期和当前期的曲线值
    var chartValues: [(name: String, values: [Double])] = []

    //当前期数据
    func getCurrentValues() -> [Double] {
        return chartValues.last?.values ?? []
    }

    //上一期数据
    func getLastValues() -> [Double] {
        return chartValues.first?.values ?? []
    }

    //当前期总值
    func getCurrentTotalValue() -> Double {
        return chartValues.last?.values.reduce(0, +) ?? 0
    }

    //上一期总值
    func getLastTotalValue() -> Double {
        return chartValues.first?.values.reduce(0, +) ?? 0
    }

    //环比同期
    func getLastPeriodTotalValue() -> Double {
        //当前期数量多于上一期，上一期取全部值
        let last = getLastValues()
        let cur = getCurrentValues()
        let lastValues = cur.count > last.count ? last : Array(last.prefix(cur.count))
        return lastValues.reduce(0, +)
    }

    //环比
    func getLinkRatio() -> Double {
        let last = getLastPeriodTotalValue()
        let delta = getCurrentTotalValue() - last
        return last == 0 ? 0 : delta / last * 100
    }
}
