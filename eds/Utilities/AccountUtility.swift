//
//  AccountUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya

class AccountUtility {

    //随机码，62^5≈10亿种组合
    private let idCount = 5

    //单例，只允许存在一个实例
    static let sharedInstance = AccountUtility()

    //当前登录工程
    var account: Account?
    //当前工程账户拥有的子账户列表
    var phoneList: [Phone] = []
    //当前登录手机用户
    var loginedPhone: Phone?

    private init() { }

    func loginSucceeded(_ account: Account, phoneNumber: String) {
        self.account = account
        phoneList = account.getPhones()
        loginedPhone = phoneList.first(where: { $0.number == phoneNumber })
    }

    /// 从后台导入列表
    func loadProjectAccount(accountID: String, phoneNumber: String) {
        //获取后台服务,请求在生命周期中只有一次
        if let _ = account {
            return
        }
        //获取最近一季度的报警记录
        let factor = EDSServiceQueryFactor(id: accountID)
        MoyaProvider<EDSService>().request(.queryAccountList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[Account?]?👉[Account]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Account]())

                if let account = (tempList?.filter { $0 != nil } as! [Account]).first {
                    self.loginSucceeded(account, phoneNumber: phoneNumber)
                }
                print("AccountUtility:Load project account.")
            default:
                break
            }
        }
    }

    func updatePhone() {
        guard let account = self.account else {
            return
        }
        account.setPhone(phones: phoneList)
        MoyaProvider<EDSService>().request(.updateAccount(account: account)) { _ in }
    }

    func getPhone(by name: String) -> Phone? {
        //兼容旧数据，name和phone在一起：e.g.:徐海生-100000000000
        let validName = name.separateNameAndPhone().name
        return phoneList.first { $0.name == validName }
    }

    //EDS Service工单、记录等数据模型需要ID
    func generateID() -> String {
        return "\(account?.id ?? NIL)-\(String.randomString(length: idCount))"
    }

    func generateImageID() -> String {
        let project = account?.id.replacingOccurrences(of: "/", with: "_")
        return "\(project ?? NIL)_\(String.randomString(length: idCount))"
    }
}
