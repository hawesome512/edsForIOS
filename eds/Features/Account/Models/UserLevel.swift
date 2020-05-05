//
//  UserLevel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  一个用户拥有：
//      一个工程管理员账号，同于webaccess的用户名➕密码，一般不授权给客户，只有客户不能使用手机验证的情况下授予
//      一个管理员账号，拥有所有操作权限，可转移管理员账号给其他人
//      若干操作员
//      若干观察员
//      若干临时访客

import Foundation
import HandyJSON

enum UserLevel: Int, HandyJSONEnum, Comparable {

    //工程管理员
    case systemAdmin = 0
    //管理员
    case phoneAdmin = 1
    //操作员
    case phoneOperator = 2
    //观察员
    case phoneObserver = 3
    //临时访客，扫码登录，限时，一次性
    case qrcodeObserver = 4
    //预留，超级管理员，EDS开发人员专有，可以修改EDS系统、发布工单等
    case superAdmin = 5
    //预留，未登录，初始化用，不能进入系统
    case unLogin = 6

    func getIcon() -> UIImage? {
        switch self {
        case .systemAdmin, .phoneAdmin:
            return UIImage(named: "manager")
        case .phoneOperator:
            return UIImage(systemName: "wrench")
        case .phoneObserver:
            return UIImage(systemName: "eye")
        case .qrcodeObserver:
            return UIImage(systemName: "hourglass")
        case .superAdmin:
            return UIImage(named: "offical")
        default:
            return UIImage(systemName: "person")
        }
    }

    func getTintColor() -> UIColor {
        switch self {
        case .systemAdmin, .phoneAdmin:
            return .systemRed
        case .phoneOperator:
            return .systemBlue
        case .phoneObserver:
            return .systemGreen
        case .qrcodeObserver:
            return .systemGray
        case .superAdmin:
            return .systemYellow
        default:
            return .systemGray
        }
    }

    func getText() -> String {
        return String(describing: self).localize()
    }


    static func < (lhs: UserLevel, rhs: UserLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
