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
}
