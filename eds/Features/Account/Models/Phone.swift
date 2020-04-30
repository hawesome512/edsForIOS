//
//  Phone.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  手机用户

import Foundation


class Phone: Comparable {


    private let infoSeparator = "/"

    var number: String?
    var level: UserLevel = .phoneObserver
    var name: String?
    var email: String = "shihlineds@xseec.cn"
    var photo: String = "eds"

    init() { }

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
            level = UserLevel(rawValue: Int(infos[1]) ?? UserLevel.phoneObserver.rawValue) ?? UserLevel.phoneObserver
            fallthrough
        default:
            number = infos[0]
        }
    }

    func toString() -> String? {
        guard let number = self.number, let name = self.name else {
            return nil
        }
        return number + infoSeparator + "\(level.rawValue)" + infoSeparator + name + infoSeparator + photo + infoSeparator + email
    }

    func isOperable() -> Bool {
        return level.rawValue <= UserLevel.phoneOperator.rawValue
    }

    //当前管理员用户可以升降操作员和观察员的权限，不能修改自己的权限，自能转移管理员
    func switchLevel() {
        switch level {
        case .phoneOperator:
            level = .phoneObserver
        case .phoneObserver:
            level = .phoneOperator
        default:
            break
        }
    }

    func prepareSaved() -> Bool {
        //核对必要信息是否完善
        let nessary = [number, level.getText(), name]
        return !nessary.contains { $0 == nil || $0!.isEmpty }
    }

    static func < (lhs: Phone, rhs: Phone) -> Bool {
        return lhs.level.rawValue < rhs.level.rawValue
    }

    static func == (lhs: Phone, rhs: Phone) -> Bool {
        lhs.number == rhs.number
    }
}


