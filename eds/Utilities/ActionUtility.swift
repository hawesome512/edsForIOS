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
    var actionList: [Action] = []
    var successfulLoaded = BehaviorRelay<Bool>(value: false)

    private init () { }

    func loadProjectActionList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard actionList.count == 0, let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        let factor = EDSServiceQueryFactor(id: projID, in: .month)
        MoyaProvider<EDSService>().request(.queryActionList(factor: factor)) { result in
            switch(result) {
            case .success(let response):
                if let temps = JsonUtility.getEDSServiceList(with: response.data, type: [Action]()) {
                    self.actionList = (temps.filter { $0 != nil } as! [Action]).reversed()
                    self.successfulLoaded.accept(true)
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
        MoyaProvider<EDSService>().request(.updateAction(action: action)) { _ in }
    }
}
