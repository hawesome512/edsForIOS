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

    func toString() -> String {
        //因英文状态下分号为分隔符，content自身的分隔符要移除
        let validContent = content?.replacingOccurrences(of: ";", with: " ")
        return "\(name!)_\(date!)_\(validContent!)"
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
        msg.name = AccountUtility.sharedInstance.loginedPhone?.name
        msg.content = validContent
        msg.date = Date().toDateTimeString()
        return msg
    }

    func getType() -> (type: MessageType, attrText: NSAttributedString?) {
        guard let content = content else {
            return (.text, nil)
        }
        let range = NSRange(location: 0, length: content.count)
        //报警ID：2/XRD-20200101010101
        var pattern = "\\d/\\w{3}-\\d+"
        var regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        let attrText = NSMutableAttributedString(string: content, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        if let _ = regex?.firstMatch(in: content, options: [], range: range) {
            attrText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemYellow, range: range)
            return (.alarm, attrText)
        }
        //参考文件：配电房巡检制度.pdf
        pattern = "\\.pdf$"
        regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        if let _ = regex?.firstMatch(in: content, options: [], range: range) {
            attrText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: range)
            return (.instruction, attrText)
        }
        return (.text, NSAttributedString(string: content, attributes: nil))
    }
}

//留言类型：网页（EDSServlet/upload/workorder文档、视频、网页），报警工单中报警ID，普通文本
enum MessageType {
    case instruction
    case alarm
    case text
}
