//
//  WorkorderMessage.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

struct WorkorderMessage {
    private static let separator = "_"

    var name: String?
    var date: String?
    var content: String?

    private init() { }

    mutating func toString() -> String {
        //因英文状态下分号为分隔符，content自身的分隔符要移除
        content = content?.replacingOccurrences(of: ";", with: " ")
        return "\(name!)_\(date!)_\(content!)"
    }


    /// 从服务器中返回的数据解析到APP中
    /// - Parameter message: <#message description#>
    static func decode(with message: String) -> WorkorderMessage? {
        //e.g.:xhs_2012-12-12 12:12:12_this is a message!
        let pattern = "(\\w+)_(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2})_(.+)"
        let range = NSRange(location: 0, length: message.count)
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: message, options: [], range: range) {
            var msg = WorkorderMessage()
            msg.name = (message as NSString).substring(with: result.range(at: 1))
            msg.date = (message as NSString).substring(with: result.range(at: 2))
            msg.content = (message as NSString).substring(with: result.range(at: 3))
            return msg
        } else {
            return nil
        }
    }


    /// APP👉服务器，新增一条留言+当前时间，当前用户
    /// - Parameter content: <#content description#>
    static func encode(with content: String) -> WorkorderMessage {
        //过滤留言信息主体中可能存在的分隔符
        let validContent = content.replacingOccurrences(of: WorkorderMessage.separator, with: " ")
        var msg = WorkorderMessage()
        msg.name = AccountUtility.sharedInstance.phone?.name
        msg.content = validContent
        msg.date = Date().toDateTimeString()
        return msg
    }
}
