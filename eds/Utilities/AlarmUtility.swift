//
//  AlarmUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import RxCocoa

class AlarmUtility {
    
    //单例，只允许存在一个实例
    static let sharedInstance = AlarmUtility()
    
    var successfulUpdated = BehaviorRelay<Bool>(value: false)
    //通过单列调取报警列表
    private var alarmList: [Alarm] = []
    
    private init() { }
    
    /// 从后台导入报警列表
    func loadProjectAlarmList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard alarmList.count == 0, let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        //获取最近一年的报警记录(太久远的报警记录无意义）
        let factor=EDSServiceQueryFactor(id: projID, in: .year)
        EDSService.getProvider().request(.queryAlarmList(factor: factor)) { result in
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
                self.successfulUpdated.accept(true)
                print("AlarmUtility:Load project alarm list in the last year.")
            default:
                break
            }
        }
    }
    
    func getAlarmList()->[Alarm]{
        //登录时更新数据失败的情况（排除工程中本来没有异常数据）
        if alarmList.count==0,!successfulUpdated.value {
            loadProjectAlarmList()
        }
        return alarmList
    }
    
    func getClassifiedAlarm()->Dictionary<AlarmConfirm,[Alarm]>{
        var result:Dictionary<AlarmConfirm,[Alarm]> = [:]
        AlarmConfirm.allCases.forEach{confirm in
            result[confirm] = alarmList.filter{$0.confirm == confirm}
        }
        return result
    }
    
    func clearAlarmList(){
        alarmList.removeAll()
        successfulUpdated.accept(false)
    }
    
    func get(by id: String) -> Alarm? {
        return alarmList.first { $0.id == id }
    }
    
    func check(_ alarm:Alarm) {
        alarm.confirm.toggle()
        EDSService.getProvider().request(.updateAlarm(alarm: alarm)) { _ in }
        let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device)?.title ?? alarm.device
        let log = "\(device) at \(alarm.time)"
        ActionUtility.sharedInstance.addAction(.checkAlarm, extra: log)
        
        successfulUpdated.accept(true)
    }
    
    func remove(_ alarm:Alarm) {
        alarmList.removeAll(where: { $0.id == alarm.id })
        alarm.prepareForDelete()
        EDSService.getProvider().request(.updateAlarm(alarm: alarm)) { _ in }
        let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device)?.title ?? alarm.device
        let log = "\(device) at \(alarm.time)"
        ActionUtility.sharedInstance.addAction(.deleteAlarm, extra: log)
        
        successfulUpdated.accept(true)
    }
    
    
    /// 创建异常工单时更新异常信息
    func update(_ workorderAlarm:Alarm) {
        EDSService.getProvider().request(.updateAlarm(alarm: workorderAlarm)) { _ in }
        
        successfulUpdated.accept(true)
    }
}
