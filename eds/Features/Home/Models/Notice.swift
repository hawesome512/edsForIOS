//
//  Notice.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  公告栏

import Foundation
import SwiftDate

struct Notice {
    private static let separator = "_"
    //公告内容
    var message: String = ""
    //发布者
    var author: String = ""
    //截止日期
    var deadline: Date?

    mutating func toString() -> String {
//        let validMsg = message.replacingOccurrences(of: Notice.separator, with: " ")
        //防止人为输入中存在分隔符
        message.removeCharacters(chars: "_")
        let date = deadline ?? Date()
        return message + Notice.separator + date.toDateTimeString() + Notice.separator + author
    }

    static func getNotice(with info: String) -> Notice? {
        let infos = info.components(separatedBy: Notice.separator)
        guard infos.count == 3 else {
            return nil
        }
        var notice = Notice()
        notice.message = infos[0]
        notice.author = infos[2]
        //公告失效时间不包含当天，所以取now为当天起始时间
        let now = DateInRegion(Date(), region: .current).dateAtStartOf(.day)
        if let endDate = DateInRegion(infos[1], format: nil, region: .current), endDate.isAfterDate(now, granularity: .second) {
            notice.deadline = endDate.date
            return notice
        }
        return nil
    }
}
