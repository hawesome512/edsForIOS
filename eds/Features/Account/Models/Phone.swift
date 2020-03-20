//
//  Phone.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  手机用户

import Foundation


class Phone {

    private let infoSeparator = "/"

    var number: String?
    var level: UserLevel?
    var name: String?
    var email: String?
    var photo: String?

    init(with info: String) {
        let infos = info.components(separatedBy: infoSeparator)
        switch infos.count {
        case 5:
            email = infos[4]
            fallthrough
        case 4:
            photo = infos[3]
            fallthrough
        case 3:
            name = infos[2]
            fallthrough
        case 2:
            level = UserLevel(rawValue: Int(infos[1]) ?? UserLevel.phoneGuest.rawValue)
            fallthrough
        default:
            number = infos[0]
        }
    }
}


