//
//  String-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/7.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation

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
        return NSLocalizedString(self, comment: prefix.isEmpty ? self : "\(prefix)_\(self)")
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

    func getEDSServletImageUrl() -> URL {
        return URL(string: "\(EDSConfig.servicePath):8443/EDSServlet/upload/\(self).png")!
    }


    /// 静态方法生成固定长度的随机字符串
    /// - Parameter length: <#length description#>
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
