//
//  EnergyCellType.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

enum EnergyCellType: Int, CaseIterable {
    case segment
    case chart
    case ratio
    case analysis
    case time
    case branch

    static func getAllCells() -> Dictionary<EnergyCellType, UITableViewCell> {
        var results: Dictionary<EnergyCellType, UITableViewCell> = [:]
        results[.segment] = EnergySegmentCell()
        results[.chart] = DeviceTrendChartCell()
        results[.analysis] = DeviceTrendAnalysisCell()
        results[.ratio] = EnergyRatioCell()
        results[.time] = EnergyTimeCell()
        results[.branch] = EnergyBranchCell()
        return results
    }
}
