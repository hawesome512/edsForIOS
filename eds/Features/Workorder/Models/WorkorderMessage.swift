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
    var user: User?
    var date: String?
    var content: String?

    private init() { }

    mutating func toString() -> String {
        //因英文状态下分号为分隔符，content自身的分隔符要移除
        content = content?.replacingOccurrences(of: ";", with: " ")
        //权限管理后，待完善
        
        return ""
    }

    static func generate(with message: String) -> WorkorderMessage? {
        //e.g.:xhs_2012-12-12 12:12:12_this is a message!
        let pattern = "(\\w+)_(\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2})_(.+)"
        let range = NSRange(location: 0, length: message.count)
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: message, options: [], range: range) {

            let name = (message as NSString).substring(with: result.range(at: 1))
            let user = User.tempInstance
            user.name = name
            var msg = WorkorderMessage()
            msg.user = user
            msg.date = (message as NSString).substring(with: result.range(at: 2))
            msg.content = (message as NSString).substring(with: result.range(at: 3))
            return msg
        } else {
            return nil
        }
    }
}
