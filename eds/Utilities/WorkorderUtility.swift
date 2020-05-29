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
    //单例，只允许存在一个实例
    static let sharedInstance = WorkorderUtility()
    var successfulUpdated = BehaviorRelay<Bool>(value: false)
    //通过单列调取工单列表
    private var workorderList: [Workorder] = []
    
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
                print("WorkorderUtility:Load project workorder list.")
            default:
                break
            }
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
    
    func getWorkorderList()->[Workorder]{
        if workorderList.count==0,!successfulUpdated.value{
            loadProjectWorkerorderList()
        }
        return workorderList
    }
    
    
    /// 分类：逾期，计划，完成
    /// - Returns: <#description#>
    func getClassifiedWorkorders()->Dictionary<FlowTimeLine,[Workorder]>{
        var results:Dictionary<FlowTimeLine,[Workorder]> = [:]
        FlowTimeLine.allCases.forEach({flow in
            results[flow] = workorderList.filter{$0.getFlowTimeLine()==flow}
        })
        return results
    }
    
    private func addWorkorderList(_ workorders:[Workorder?]?){
        let tempList=(workorders?.filter { $0 != nil })! as! [Workorder]
        tempList.forEach{
            if !workorderList.contains($0){
                workorderList.append($0)
            }
        }
        //按执行时间的先后排序，逆序
        workorderList.sort()
        workorderList.reverse()
        successfulUpdated.accept(true)
    }
    
    func update(with workorder: Workorder) {
        if let index = workorderList.firstIndex(where: { $0.id == workorder.id }) {
            workorderList[index] = workorder
        } else {
            workorderList.insert(workorder, at: 0)
        }
        successfulUpdated.accept(true)
    }
    
    func removeWorkorder(_ workorder:Workorder){
        workorder.prepareDeleted()
        EDSService.getProvider().request(.updateWorkorder(workorder: workorder)) { _ in }
        ActionUtility.sharedInstance.addAction(.deleteWorkorder, extra: workorder.title)
        workorderList.removeAll(where: {$0.id == workorder.id})
        successfulUpdated.accept(true)
    }
    
    func clearWorkorderList(){
        workorderList.removeAll()
        successfulUpdated.accept(false)
    }
}
