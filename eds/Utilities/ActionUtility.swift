//
//  ActionUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import RxCocoa

class ActionUtility {
    
    static let sharedInstance = ActionUtility()
    private(set) var actionList: [Action] = []
    private(set) var successfulUpdated = BehaviorRelay<Bool>(value: false)
    
    private init () { }
    
    func loadProjectActionList() {
        guard let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        //获取最近一个月的报警记录（操作记录可能比较多）
        let factor=EDSServiceQueryFactor(id: projID, in: .month)
        EDSService.getProvider().request(.queryActionList(factor: factor)) { result in
            switch(result) {
            case .success(let response):
                if let temps = JsonUtility.getEDSServiceList(with: response.data, type: [Action]()) {
                    self.actionList = (temps.filter { $0 != nil } as! [Action]).reversed()
                    self.successfulUpdated.accept(true)
                    print("load proj action list.")
                }
            default:
                break
            }
        }
    }
    
    func getAction(by user: String) -> [Action] {
        return actionList.filter { $0.user == user }
    }
    
    func addAction(_ type: ActionType, extra: String? = nil) {
        guard let username = AccountUtility.sharedInstance.loginedPhone?.name, let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        let action = Action()
        let date = Date()
        action.id = projID + "-" + date.toIDString()
        action.user = username
        action.addAction(type, extra: extra)
        action.time = date.toDateTimeString()
        EDSService.getProvider().request(.updateAction(action: action)) { _ in }
        actionList.insert(action, at: 0)
        successfulUpdated.accept(true)
    }
    
    
    /// 退出前清空资源
    func clearAction(){
        actionList.removeAll()
        successfulUpdated.accept(false)
    }
    
}
