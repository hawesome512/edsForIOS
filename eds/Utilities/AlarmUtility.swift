//
//  AlarmUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya

class AlarmUtility {
    //通过单列调取报警列表
    var alarmList: [Alarm] = []
    //单例，只允许存在一个实例
    static let sharedInstance = AlarmUtility()

    private init() { }

    /// 从后台导入报警列表
    func loadProjectAlarmList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard alarmList.count == 0 else {
            return
        }
        //获取最近一季度的报警记录
        let factor = EDSServiceQueryFactor(id: User.tempInstance.projectID!, in: .halfYear)
        MoyaProvider<EDSService>().request(.queryAlarmList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[alarm?]?👉[alarm]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Alarm]())
                self.alarmList = (tempList?.filter { $0 != nil })! as! [Alarm]
                //默认排序按alarm.time先后:整理是否已经排查，逆序处理使最近发生的优先排列
                self.alarmList.sort { item1, item2 in
                    return item1.confirm == .checked
                }
                self.alarmList.reverse()
                print("AlarmUtility:Load project alarm list in recent quarter.")
            default:
                break
            }
        }
    }

    func get(by id: String) -> Alarm? {
        return alarmList.first { $0.id == id }
    }

    func check(with id: String) {
        alarmList.first { $0.id == id }?.confirm = .checked
    }

    func remove(with id: String) {
        alarmList.removeAll { $0.id == id }
    }

    func workorder(_ id: String, workorderID: String) {
        alarmList.first { $0.id == id }?.report = workorderID
    }
}
