//
//  Action.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/14.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  用户操作记录，全部由终端产生，记录用户在APP上的行为

import Foundation
import HandyJSON

class Action: HandyJSON {

    //🆔，e.g.：1/XRD-20191201121212（projecID-时间戳）
    var id = ""
    //操作用户，当前登录账户
    var user = ""
    //操作行为，登录、修改、执行……
    var action = ""
    //记录时间，e.g.：2019-12-01 12:12:12
    var time = ""

    required init() { }

    init(actionID: String, username: String, info: String) {
        id = actionID
        user = username
        action = info
        //action都是从App生成
        time = Date().toDateTimeString()
    }
}
