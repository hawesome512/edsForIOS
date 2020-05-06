//
//  String-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/7.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension String {

    //Base64解码
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    //Base64编码
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    //URL编码
    func toURLEncoding() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    //EDS Service Response 删除字符串中\"null\"代表nil的选项
    //由于服务器数据接口不统一，存在“null"和“”null“”两种数据，使用正则表达式处理
    func removeNull() -> String {
        guard let regex = try? NSRegularExpression(pattern: "(\\\")+null(\\\")+", options: .caseInsensitive) else {
            return self
        }
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: "\"\"")
    }


    /// 本地化
    /// - Parameter prefix: 前缀，e.g.：device_status
    func localize(with prefix: String = "") -> String {
        let value = prefix.isEmpty ? self : "\(prefix)_\(self)"
        return NSLocalizedString(value, comment: value)
    }

    /// Name带单位时格式化文本，单位：灰色
    /// - Parameter input: Ir(xIn)
    func formatNameAndUnit() -> NSAttributedString {
        if let index = self.firstIndex(of: "(") {
            let attrStr = NSMutableAttributedString(string: self.prefix(upTo: index).description, attributes: [NSAttributedString.Key.foregroundColor: edsDefaultColor])
            attrStr.append(NSAttributedString(string: self.suffix(from: index).description, attributes: [NSAttributedString.Key.foregroundColor: edsGrayColor]))
            return attrStr
        }
        return NSAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor: edsDefaultColor])
    }

    func separateNameAndUnit() -> (name: String, unit: String?) {
        let range = NSRange(location: 0, length: self.count)
        //匹配规则：起始(^)   分组1⃣️（非括号字符）   左括号    分组2⃣️（非括号字符）   右括号    结束($)
        let regex = try? NSRegularExpression(pattern: "^([^\\(\\)]+)\\(([^\\(\\)]+)\\)$", options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: self, options: [], range: range) {
            let v = (self as NSString).substring(with: result.range(at: 1))
            let u = (self as NSString).substring(with: result.range(at: 2))
            return (v, u)
        } else {
            return (self, nil)
        }
    }


    /// 验证是否是固定长度的字符串
    func verifyValidNumber(count: Int) -> Bool {
        let range = NSRange(location: 0, length: self.count)
        let regex = try? NSRegularExpression(pattern: "^\\d{\(count)}$", options: .allowCommentsAndWhitespace)
        if let _ = regex?.firstMatch(in: self, options: [], range: range) {
            return true
        } else {
            return false
        }
    }

    /// 分离用户名和电话号码，e.g.:hawesome-123456,hawesome 123456
    func separateNameAndPhone() -> (name: String, phone: String?) {
        let range = NSRange(location: 0, length: self.count)
        let regex = try? NSRegularExpression(pattern: "(\\w+)\\W+(\\d+)", options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: self, options: [], range: range) {
            let v = (self as NSString).substring(with: result.range(at: 1))
            let u = (self as NSString).substring(with: result.range(at: 2))
            return (v, u)
        } else {
            return(self, nil)
        }
    }


    /// 提取异常码：异常[123]👉123
    func getAlarmCode() -> String? {
        let range = NSRange(location: 0, length: self.count)
        let regex = try? NSRegularExpression(pattern: "异常\\[(\\d+)\\]", options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: self, options: [], range: range) {
            return (self as NSString).substring(with: result.range(at: 1))
        }
        return nil
    }


    /// EDS图片在服务器中的地址
    func getEDSServletImageUrl() -> URL {
        //历史遗留，已存在xxx.jpg or xxx.jpeg 数据
        let image = self.contains(".") ? self : "\(self).png"
        return URL(string: "\(EDSConfig.servicePath):8443/EDSServlet/upload/\(image)")!
    }


    /// EDS运维指导文件在服务器中的地址
    func getEDSServletWorkorderDocUrl() -> String {
        return "\(EDSConfig.servicePath):8443/EDSServlet/upload/workorder/\(self)"
    }


    /// EDS使用教程文件在服务器中的地址
    func getEDSServletHelpURL() -> String {
        return "\(EDSConfig.servicePath):8443/EDSServlet/upload/help/\(self)"
    }

    func getImageNameFromURL() -> String {
        return self.components(separatedBy: "/").last ?? NIL
    }

    /// 静态方法生成固定长度的随机字符串
    /// - Parameter length: <#length description#>
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
