//
//  EnergySegmentType.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import SwiftDate

enum EnergySegmentType: Int, CaseIterable {
    case day
    case month
    case year

    func getText() -> String {
        return String(describing: self).localize(with: prefixEnergy)
    }

    func getDates() -> [EnergyDateItem] {
        let now = DateInRegion(Date(), region: .current)
        var dates: [EnergyDateItem] = []
        switch self {
        case .day:
            //过去一个月的天数
            var start = (now - 1.months).dateAtStartOf(.day)
            while start.isBeforeDate(now, granularity: .second) {
                dates.append(EnergyDateItem(start, type: self))
                start = start + 1.days
            }
        case .month:
            //过去一年的月份
            var start = (now - 1.years).dateAtStartOf(.month)
            while start.isBeforeDate(now, granularity: .second) {
                dates.append(EnergyDateItem(start, type: self))
                start = start + 1.months
            }
        case .year:
            //过去三年的年份
            var start = (now - 3.years).dateAtStartOf(.year)
            while start.isBeforeDate(now, granularity: .second) {
                dates.append(EnergyDateItem(start, type: self))
                start = start + 1.years
            }
            break
        }
        return dates
    }
    
    
}
