//
//  Action.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/14.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  用户操作记录，全部由终端产生，记录用户在APP上的行为

import Foundation
import HandyJSON
import SwiftDate

class Action: HandyJSON, Comparable {

    private let actionSeparator = "_"

    //🆔，e.g.：1/XRD-20191201121212（projecID-时间戳）
    var id = ""
    //操作用户，当前登录账户
    var user = ""
    //操作行为，登录、修改、执行……
    var action = ""
    //记录时间，e.g.：2019-12-01 12:12:12
    var time = ""

    required init() { }


    /// 新增记录
    /// - Parameters:
    ///   - type: 记录类型，e.g. :contrlDevice
    ///   - extra: 附加信息，e.g. :设备ID
    func addAction(_ type: ActionType, extra: String?) {
        action = type.rawValue
        if let extra = extra?.replacingOccurrences(of: actionSeparator, with: " ") {
            action += actionSeparator + extra
        }
    }


    /// 获取记录信息，相对于👆新增记录
    func getActionInfo() -> (type: ActionType, text: String) {
        let infos = action.components(separatedBy: actionSeparator)
        let actionType = ActionType(rawValue: infos[0]) ?? .other
        let actionText = actionType.rawValue.localize(with: prefixAction)
        if infos.count == 2 {
            return (actionType, actionText + " " + infos[1])
        } else {
            return (actionType, actionText)
        }
    }


    /// 获取用户记录简短信息，用于显示在用户列表中
    func getShortInfo() -> String {
        let date = DateInRegion(time, format: nil, region: .current)?.date.toShortDateString() ?? ""
        return date + " : " + getActionInfo().type.rawValue.localize(with: prefixAction)
    }

    static func < (lhs: Action, rhs: Action) -> Bool {
        return lhs.id < rhs.id
    }

    static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.id == rhs.id
    }
}


enum ActionType: String {
    //登录
    case login
    //其他
    case other

    //在操作记录列表中用于区分操作类型的外观
    func getView() -> (icon: UIImage?, color: UIColor) {
        switch self {
        default:
            return (UIImage(systemName: "person.circle"), .systemGray)
        }
    }
}
