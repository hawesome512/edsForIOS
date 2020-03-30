//
//  Account.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import HandyJSON

class Account: HandyJSON {

    let phoneSeparator = ";"

    // MARK: - EDSService
    //🆔，e.g.：1/XRD
    var id = ""
    //权限
    var authority = ""
    //授权手机账户数量
    var number = 0
    //资产管理设备数量
    var device = 0
    //手机账户信息
    var phone = ""
    
    required init() { }

    func getPhones() -> [Phone] {
        return phone.components(separatedBy: phoneSeparator).map { Phone(with: $0) }
    }
}
