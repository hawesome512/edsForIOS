//
//  WorkorderUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import RxCocoa

class WorkorderUtility {
    //通过单列调取工单列表
    private var workorderList: [Workorder] = []
    //为降低一次发送的数据量，每次请求数据限定时间（1月、季度、半年或年）
    //单例，只允许存在一个实例
    static let sharedInstance = WorkorderUtility()
    var successfulLoaded = BehaviorRelay<Bool>(value: false)
    
    private init() { }
    
    /// 从后台导入列表
    func loadProjectWorkerorderList() {

        guard let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        
        //获取所有的工单记录
        let factor = EDSServiceQueryFactor(id: projID, in: .none)
        EDSService.getProvider().request(.queryWorkorderList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[Workorder?]?👉[Workorder]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Workorder]())
                //按执行时间的先后排序，逆序
//                self.workorderList = ((tempList?.filter { $0 != nil })! as! [Workorder]).sorted().reversed()
                self.addWorkorderList(tempList)
                self.successfulLoaded.accept(true)
                print("WorkorderUtility:Load project workorder list in recent quarter.")
            default:
                break
            }
        }
    }
    
    func update(with workorder: Workorder) {
        if let index = workorderList.firstIndex(where: { $0.id == workorder.id }) {
            workorderList[index] = workorder
        } else {
            workorderList.insert(workorder, at: 0)
        }
    }
    
    func get(by id: String) -> Workorder? {
        return workorderList.first(where: { $0.id == id })
    }
    
    //获取权重最高的工单
    func getMyWorkorder() -> Workorder? {
        let accountName = AccountUtility.sharedInstance.loginedPhone?.name
        return workorderList.sorted(by: { (lhs, rhs) -> Bool in
            lhs.calWeightCoefficient(with: accountName) > rhs.calWeightCoefficient(with: accountName)
        }).first
    }
    
    func addWorkorderList(_ workorders:[Workorder?]?){
        let tempList=(workorders?.filter { $0 != nil })! as! [Workorder]
        tempList.forEach{
            if !workorderList.contains($0){
                workorderList.append($0)
            }
        }
        //按执行时间的先后排序，逆序
        workorderList.sort()
        workorderList.reverse()
    }
    
    func getWorkorderList()->[Workorder]{
        if workorderList.count==0,!successfulLoaded.value{
            loadProjectWorkerorderList()
        }
        return workorderList
    }
    
    func clearWorkorderList(){
        workorderList.removeAll()
    }
    
    func removeWorkorder(_ id:String){
        workorderList.removeAll(where: {$0.id == id})
    }
}
