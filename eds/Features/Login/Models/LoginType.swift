//
//  LoginType.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/8.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

enum LoginType: String {
    //手机快捷登录
    case phoneType
    //帐号密码登录
    case passwordType
    //二维码登录
    case scanType

    func toString() -> String {
        return self.rawValue.localize(with: prefixLogin)
    }

    /// 登录方式切换
    func toggle() -> LoginType {
        switch self {
        case .phoneType:
            return .passwordType
        case .passwordType:
            return .phoneType
        default:
            return self
        }
    }


    /// 用户名+密码 or 手机号码+验证码
    func getItems() -> [String] {
        switch self {
        case .phoneType:
            return ["phone".localize(with: prefixLogin), "code".localize(with: prefixLogin)]
        case .passwordType:
            return ["username".localize(with: prefixLogin), "password".localize(with: prefixLogin)]
        default:
            return []
        }
    }

}
