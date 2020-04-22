//
//  File.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  能耗查询数据转换模型

import Foundation
import SwiftDate

class EnergyData {
    var dateItem: EnergyDateItem
    //上一期和当前期的曲线值
    var chartValues: [(name: String, values: [Double])] = []
    //支路占比,
//    var branchData: Dictionary<String, Double> = ["1F": 25, "2F": 40, "3F": 35]

    init(_ dateItem: EnergyDateItem, chartValues: [(name: String, values: [Double])]) {
        self.dateItem = dateItem
        self.chartValues = chartValues
    }

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
        return last == 0 ? 0 : delta / last * 100.0
    }

    //分时能耗
    func calTimePrice() -> Dictionary<EnergyPrice, Double> {
        var data = [EnergyPrice.valley: 0.0, EnergyPrice.plain: 0.0, EnergyPrice.peek: 0.0]
        //年摸索，数值不能精细到hour,不能进行分时统计
        guard dateItem.dateType != .year else {
            return data
        }
        getCurrentValues().enumerated().forEach { (offset, element) in
            let date = dateItem.date + offset.hours
            let priceType = EnergyPrice(hourOfDay: date.hour)
            data[priceType] = data[priceType]! + element
        }
        return data
    }
}
