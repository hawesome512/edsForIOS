//
//  EnergyDateItem.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import SwiftDate

struct EnergyDateItem {
    let dateType: EnergySegmentType
    let date: DateInRegion

    init(_ date: DateInRegion, type: EnergySegmentType) {
        self.date = date
        self.dateType = type
    }

    func getText() -> String {
        switch dateType {
        case .day:
            //月初第一天显示月份
            return date.toFormat("MMM d")
        case .month:
            //年初第一年显示年份
            if date == date.dateAtStartOf(.year) {
                return date.toFormat("yyyy")
            } else {
                return date.toFormat("MMM")
            }
        case .year:
            return date.toFormat("yyyy")
        }
    }


    /// 获取间隔点的时间显示样式，用于DeviceTrendChartCell>横坐标
    /// - Parameter index: <#index description#>
    func getShortTimeString(with index: Int) -> String {
        switch dateType {
        case .day:
            return (date + index.hours).toFormat("H:mm")
        case .month:
            //如4月（30天）3月（31天），按此处理的话第31天（4月1+31day=5月1）将显示为1
            //return (date + index.days).toFormat("d")
            return "\(index + 1)"
        case .year:
            return (date + index.months).toFormat("MMM")
        }
    }

    func getLongTimeString(with index: Int) -> String {
        switch dateType {
        case .day:
            return (date + index.hours).toFormat("yyyy MMM dd HH:mm:ss")
        case .month:
            return (date + index.days).toFormat("yyyy MMMM dd")
        case .year:
            return (date + index.months).toFormat("yyyy MMM")
        }
    }

    func getLastPeriodRecords() -> Int {
        switch dateType {
        case .day:
            return 24
        case .month:
            return (date-1.months).monthDays * 24
        case .year:
            return 12
        }
    }

    func getLogRequestCondition(with tags: [LogTag]) -> WATagLogRequestCondition {
        switch dateType {
        case .day:
            let start = (date - 1.days).dateAtStartOf(.day)
            let startTime = start.date.toDateTimeString()
            let records = (getEndDate() - start).toUnit(.hour) ?? 0
            //因电能为累加值，在换算的时候会少掉一位，在请求数据的时候+1抵消
            return WATagLogRequestCondition(startTime: startTime, intervalType: .H, interval: 1, records: records + 1, tags: tags)
        case .month:
            let start = (date - 1.months).dateAtStartOf(.month)
            let startTime = start.date.toDateTimeString()
            let records = (getEndDate() - start).toUnit(.hour) ?? 0
            return WATagLogRequestCondition(startTime: startTime, intervalType: .H, interval: 1, records: records + 1, tags: tags)
        case .year:
            let start = (date - 1.years).dateAtStartOf(.year)
            let startTime = start.date.toDateTimeString()
            let records = (getEndDate() - start).toUnit(.month) ?? 0
            return WATagLogRequestCondition(startTime: startTime, intervalType: .M, interval: 1, records: records + 1, tags: tags)
        }
    }


    /// 截止时间
    func getEndDate() -> DateInRegion {
        //不能超出当前时间
        let now = DateInRegion(Date(), region: .current)
        var end = date
        switch dateType {
        case .day:
            //e.g:3月15 0:0:0👉3月16 0:0：0算完整的一个时间周期，不从3月15 23:59:59算起，下同
            end = (date + 1.days).dateAtStartOf(.day)//.dateAtEndOf(.day)
        case .month:
            end = (date + 1.months).dateAtStartOf(.month)//date.dateAtEndOf(.month)
        case .year:
            end = (date + 1.years).dateAtStartOf(.year)//date.dateAtEndOf(.year)
        }
        return end.isAfterDate(now, granularity: .second) ? now : end
    }
}
