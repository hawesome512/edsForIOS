//
//  WorkorderFlow.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

//流程
struct WorkorderFlow {
    //工单状态
    var state: WorkorderState
    //工单时效
    var timeLine: FlowTimeLine
    //完成或截止日期
    var date: String?

    init(state: WorkorderState, workorder: Workorder) {
        self.state = state
        //默认填写截止时间
        date = workorder.end.toDate()?.date.toShortDate()

        //判定时效性
        switch state.rawValue {
        case 0...workorder.state.rawValue:
            //已完成,设置完成日期
            timeLine = .done
            setDate(flow: workorder.flow)
        case workorder.state.rawValue + 1:
            //下一个流程,对比当前时间和截止时间
            let nowTime = DateInRegion(Date(), region: .current)
            if let endTime = workorder.end.toDate(nil, region: .current), nowTime > endTime {
                timeLine = .delay
            } else {
                timeLine = .plan
            }
        default:
            //计划
            timeLine = .plan
        }
    }

    private mutating func setDate(flow: String) {
        let pattern = "(\(state.rawValue))_(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2})_(\\w+)"
        let range = NSRange(location: 0, length: flow.count)
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: flow, options: [], range: range) {
            let dateTime = (flow as NSString).substring(with: result.range(at: 2))
            date = dateTime.toDate()?.date.toShortDate()
        }
    }

    static func toFormat(state: WorkorderState, name: String) -> String {
        //工单流程存档:类型_时间_操作，e.g.:0_2020-12-12 12:12:12_徐海生
        return String(format: "%d_%@_%@", state.rawValue, Date().toDateTimeString(), name)
    }
}


//工单流程时效：已完成，逾期，计划
enum FlowTimeLine {
    case done
    case delay
    case plan

    func getState() -> (icon: UIImage?, color: UIColor) {
        switch self {
        case .done:
            return (UIImage(systemName: "checkmark.circle.fill"), .systemGreen)
        case .delay:
            return (UIImage(systemName: "bell.circle.fill"), .systemRed)
        case .plan:
            return (UIImage(systemName: "clock.fill"), .systemGray3)
        }
    }
}
