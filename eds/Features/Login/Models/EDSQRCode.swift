//
//  EDSQRCode.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/8.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  EDS专属二维码

import Foundation
import SwiftDate

struct EDSQRCode {
    //工程ID,e.g.:1/XRD
    var node: String
    //工程密钥，e.g.:authority
    var key: String
    //二维码类型
    var type: QRCodeType
    //附带参数
    var param: String

    /// 解析密钥：用户名+密码
    func getKeys() -> [String] {
        return key.fromBase64()?.components(separatedBy: ":") ?? []
    }

    /// 验证登录二维码时效，默认5分钟内
    func checkLoginValid() -> Bool {
        guard let dateParam = param.fromBase64(),
            let validTime = DateInRegion(dateParam, format: "yyyyMMddHHmmss", region: .current) else {
                return false
        }
        let nowTime = DateInRegion(Date(), region: .current)
        return (validTime + 5.minutes).isAfterDate(nowTime, granularity: .second)
    }

    static func getCode(_ info: String) -> EDSQRCode? {
        let infos = info.replacingOccurrences(of: "\n", with: "").components(separatedBy: ";").map { $0.components(separatedBy: ":") }.filter { $0.count == 2 }.map { $0[1] }
        if infos.count == 4, let intType = Int(infos[2]), let type = QRCodeType(rawValue: intType) {
            return EDSQRCode(node: infos[0], key: infos[1], type: type, param: infos[3])
        }
        return nil
    }

    static func getString(type: QRCodeType, param: String) -> String? {
        guard let account = AccountUtility.sharedInstance.account else {
            return nil
        }
        return "Node:\(account.id);Key:\(account.edskey);Type:\(type.rawValue);Param:\(param)"
    }
}
