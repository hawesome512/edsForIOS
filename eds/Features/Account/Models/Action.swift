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
    //手机快捷登录
    case phoneLogin
    //帐号密码登录
    case passwordLogin
    //发布公告
    case addNotice
    //删除公告
    case deleteNotice
    //编辑首页
    case editHome
    //编辑用电分析
    case editBranch
    //新增资产 +extra e.g.:成型1#柜
    case addDevice
    //删除资产 +extra e.g.:成型1#柜
    case deleteDevice
    //编辑资产 +extra e.g.:成型1#柜
    case editDevice
    //遥调 +extra e.g.:成型1#柜 保护功能:ON / 成型1#柜 Ir(xIn):0.4
    case paramDevice
    //遥控 +extra e.g.:成型1#柜
    case ctrlDevice
    //排查报警 +extra e.g.:成型1#柜 at 2020-01-01 12:00:00
    case checkAlarm
    //删除报警 +extra e.g.:成型1#柜 at 2020-01-01 12:00:00
    case deleteAlarm
    //新增工单 +extra e.g.:配电房巡检
    case addWorkorder
    //删除工单 +extra e.g.:配电房巡检
    case deleteWorkorder
    //派发工单 +extra e.g.:配电房巡检
    case distributeWorkorder
    //执行工单 +extra e.g.:配电房巡检
    case executeWorkorder
    //审核工单 +extra e.g.:配电房巡检
    case auditeWorkorder
    //编辑个人信息
    case editPerson
    //新增成员 +extra e.g.:张三
    case addAccount
    //删除成员 +extra e.g.:张三
    case deleteAccount
    //调整成员权限 +extra e.g.:张三
    case editAccount
    //转让管理员 +extra e.g.:张三
    case transferAccount
    //其他
    case other

    func getIcon() -> UIImage? {
        switch self {
        case .ctrlDevice, .addDevice, .editDevice, .paramDevice, .deleteDevice:
            return UIImage(systemName: "bolt.circle")
        case .checkAlarm, .deleteAlarm:
            return UIImage(systemName: "bell.circle")
        case .addWorkorder, .distributeWorkorder, .executeWorkorder, .auditeWorkorder, .deleteWorkorder:
            return UIImage(systemName: "doc.circle")
        default:
            return UIImage(systemName: "person.circle")
        }
    }

    func getColor() -> UIColor {
        switch self {
        case .deleteAlarm, .deleteDevice, .deleteAccount, .deleteWorkorder, .deleteNotice, .transferAccount, .ctrlDevice:
            return .systemRed
        case .addWorkorder, .distributeWorkorder, .auditeWorkorder, .executeWorkorder, .checkAlarm, .paramDevice, .addDevice, .addNotice, .addAccount, .editBranch, .editAccount:
            return .systemBlue
        default:
            return .systemGray
        }
    }
}
