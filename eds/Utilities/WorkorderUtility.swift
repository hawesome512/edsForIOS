//
//  WorkorderUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya

class WorkorderUtility {
    //通过单列调取工单列表
    var workorderList: [Workorder] = []
    //单例，只允许存在一个实例
    static let sharedInstance = WorkorderUtility()

    private init() { }

/// 从后台导入列表
    func loadProjectWorkerorderList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard workorderList.count == 0 else {
            return
        }
        //获取最近一季度的报警记录
        let factor = EDSServiceQueryFactor(id: User.tempInstance.projectID!, in: .none)
        MoyaProvider<EDSService>().request(.queryWorkorderList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[Workorder?]?👉[Workorder]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Workorder]())
                self.workorderList = (tempList?.filter { $0 != nil })! as! [Workorder]
                //排序

                
                print("WorkorderUtility:Load project workorder list in recent quarter.")
            default:
                break
            }
        }
    }
}
