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

    //单例，只允许存在一个实例
    static let sharedInstance = AccountUtility()

    var account: Account?
    var phoneList: [Phone] = []

    private init() { }

    /// 从后台导入列表
    func loadProjectAccount() {
        //获取后台服务,请求在生命周期中只有一次
        if let _ = account {
            return
        }
        //获取最近一季度的报警记录
        let factor = EDSServiceQueryFactor(id: User.tempInstance.projectID!, in: .none)
        MoyaProvider<EDSService>().request(.queryAccountList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[Account?]?👉[Account]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Account]())

                self.account = (tempList?.filter { $0 != nil } as! [Account]).first
                self.phoneList = self.account?.getPhones() ?? []
                print("AccountUtility:Load project account.")
            default:
                break
            }
        }
    }

    func getPhone(by name: String) -> Phone? {
        //兼容旧数据，name和phone在一起：e.g.:徐海生-100000000000
        let validName = name.separateNameAndPhone().name
        return phoneList.first { $0.name == validName }
    }
}
