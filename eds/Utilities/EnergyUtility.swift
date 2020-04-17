//
//  EnergyUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya

class EnergyUtility {


    /// 将从服务后台返回的数据转换为能耗分析模型
    /// - Parameter values: <#values description#>
    static func getEnergyData(with values: [String], dateItem: EnergyDateItem) -> EnergyData {
        var data = EnergyData()

        let doubleValues = filterAccumulatedValues(values: values)
        data.chartValues = separeteLinkValues(values: doubleValues, dateItem: dateItem)

        return data
    }

    /// 分离上一期和当前期的数据
    /// - Parameters:
    ///   - values: <#values description#>
    ///   - dateItem: <#dateItem description#>
    private static func separeteLinkValues(values: [Double], dateItem: EnergyDateItem) -> [(name: String, values: [Double])] {
        let records = dateItem.getLastPeriodRecords()
        var results = [(name: String, values: [Double])]()
        let lastValues = uniteChartValues(values: Array(values.prefix(records)), dateItem: dateItem)
        let currentValues = uniteChartValues(values: Array(values.suffix(from: records)), dateItem: dateItem)
        results.append(("last".localize(with: prefixEnergy), lastValues))
        results.append(("current".localize(with: prefixEnergy), currentValues))
        return results
    }


    /// 聚合数据用于图标显示
    /// - Parameters:
    ///   - values:
    ///   - dateItem: <#dateItem description#>
    private static func uniteChartValues(values: [Double], dateItem: EnergyDateItem) -> [Double] {
        guard dateItem.dateType == .month else {
            return values
        }
        var results: [Double] = []
        //因月模式以小时为粒度，需整合为天数据
        for i in 0..<values.count where i % 24 == 0 {
            let startIndex = i
            let endIndex = (i + 24 < values.count) ? i + 24 : values.count
            results.append(values[startIndex..<endIndex].reduce(0, +))
        }
        return results
    }

    /// 处理累加值
    /// - Parameter values: 需考虑到起始或中间因通讯中断造成的空值情况
    private static func filterAccumulatedValues(values: [String]) -> [Double] {
        var results: [Double] = []
        //空值文本（#）转换为Float将为空值
        let floatValues: [Double?] = values.map { Double($0) }
        for index in 1..<floatValues.count {
            let subFloatValue = floatValues.prefix(index)
            //当前值不为空，前面还存在有效值，进行递减操作
            if let current = floatValues[index], let last = subFloatValue.last(where: { $0 != nil }) {
                //已排除last未空的项
                results.append(current - last!)
            } else {
                //空值设定为0
                results.append(0)
            }
        }
        return results
    }

}
