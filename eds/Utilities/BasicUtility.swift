//
//  EnergyUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import SwiftDate
import RxCocoa

class BasicUtility {
    
    static let sharedInstance = BasicUtility()
    
    private var basic: Basic?
    private(set) var successfulBasicInfoUpdated = BehaviorRelay<Bool?>(value: nil)
    
    private init() { }
    
    func loadProjectBasicInfo() {
        guard let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        let factor = EDSServiceQueryFactor(id: projID)
        EDSService.getProvider().request(.queryProjectInfoList(factor: factor)) { result in
            switch result {
            case .success(let response):
                self.basic = JsonUtility.getEDSServiceList(with: response.data, type: [Basic]())?.first ?? nil
                self.successfulBasicInfoUpdated.accept(true)
                print("load project basic info")
            default:
                self.successfulBasicInfoUpdated.accept(false)
            }
        }
    }
    
    
    // MARK: - 数据开放接口
    
    func getBasic()->Basic?{
        //loaded=nil正在请求数据，此时不再额外请求
        if basic==nil,let loaded=successfulBasicInfoUpdated.value,!loaded {
            loadProjectBasicInfo()
        }
        return basic
    }
    
    /// 退出前清空资源
    func clearInfo(){
        basic=nil
        successfulBasicInfoUpdated.accept(nil)
    }
    
    func updateNotice(_ notice: String) {
        basic?.notice = notice
        updateProject(saveActionLog: false)
    }
    
    func updateUser(_ title: String) {
        basic?.user = title
        updateProject()
    }
    
    func updateLocation(_ location: String) {
        basic?.location = location
        updateProject()
    }
    
    func updateBanner(_ banner: String) {
        basic?.banner = banner
        updateProject()
    }
    
    /// 变更工程负责人，通常即为手机管理员。（报警短信接收者），在转让管理员时附带执行此更新
    /// - Parameter pricipal: <#pricipal description#>
    func updatePricipal(_ pricipal: Phone) {
        basic?.setPricipal(with: pricipal)
        updateProject(saveActionLog: false)
    }
    
    
    /// 更新工程信息
    /// - Parameter saveActionLog: false➡️调用前已保存相应操作记录
    private func updateProject(saveActionLog: Bool = true) {
        guard let basic = basic else {
            return
        }
        EDSService.getProvider().request(.updateProject(projectInfo: basic)) { result in
            switch result {
            case .success(let response):
                guard JsonUtility.didUpdatedEDSServiceSuccess(data: response.data) else { return }
                if saveActionLog {
                    ActionUtility.sharedInstance.addAction(.editHome)
//                    self.successfulBasicInfoUpdated.accept(true)
                }
            default:
                break
            }
        }
        //为保证在界面上及时看到编辑更新，不等待上传数据成功再发布通知
        self.successfulBasicInfoUpdated.accept(true)
    }
    
}
