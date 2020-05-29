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
    
    private var energyBranch: EnergyBranch?
    private var basic: Basic?
    var successfulLoadedBasicInfo = BehaviorRelay<Bool?>(value: nil)
    var successfulLoadedEnergyData = BehaviorRelay<Bool?>(value: nil)
    
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
                self.successfulLoadedBasicInfo.accept(true)
                self.loadProjectEnergyData()
                print("load project basic info")
            default:
                self.successfulLoadedBasicInfo.accept(false)
            }
        }
    }
    
    private func loadProjectEnergyData() {
        guard let authority = AccountUtility.sharedInstance.account?.authority else {
            return
        }
        guard let basic = basic else {
            return
        }
        initBranch(branchInfo: basic.energy)
        
        guard let energyBranch = energyBranch else {
            return
        }
        
        let logTags = energyBranch.getLogTags()
        let date = DateInRegion(Date(), region: .current).dateAtStartOf(.month)
        let dateItem = EnergyDateItem(date, type: .month)
        let condition = dateItem.getLogRequestCondition(with: logTags)
        WAService.getProvider().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let results = JsonUtility.getTagLogValues(data: response.data) ?? []
                //获得完整数据
                guard results.count == logTags.count else {
                    return
                }
                let _ = BasicUtility.updateBranchData(in: energyBranch, with: results, dateItem: dateItem)
                self.successfulLoadedEnergyData.accept(true)
                print("loaded project energy data")
                break
            default:
                self.successfulLoadedEnergyData.accept(false)
            }
        }
    }
    
    // MARK: - 数据开放接口
    
    func getBasic()->Basic?{
        //loaded=nil正在请求数据，此时不再额外请求
        if basic==nil,let loaded=successfulLoadedBasicInfo.value,!loaded {
            loadProjectBasicInfo()
        }
        return basic
    }
    
    func getEnergyBranch()->EnergyBranch?{
        if energyBranch==nil,let loaded=successfulLoadedEnergyData.value,!loaded {
            loadProjectEnergyData()
        }
        return energyBranch
    }
    
    
    /// 退出前清空资源
    func clearInfo(){
        basic=nil
        energyBranch=nil
        successfulLoadedBasicInfo.accept(nil)
        successfulLoadedEnergyData.accept(nil)
    }
    
    func updateNotice(_ notice: String) {
        basic?.notice = notice
        updateProject(saveActionLog: false)
    }
    
    func updateBranch(_ branch: String) {
        basic?.energy = branch
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
                if JsonUtility.didUpdatedEDSServiceSuccess(data: response.data), saveActionLog {
                    ActionUtility.sharedInstance.addAction(.editHome)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - 用电支路
    
    private func initBranch(branchInfo: String) {
        let branches = EnergyBranch.getLevelBranches(branchInfo)
        switch branches.count {
        case 0:
            return
        case 1:
            energyBranch = branches[0]
        default:
            //若第1⃣️级支路超过1个，另设顶级支路，以所有第1⃣️级支路值为其支路
            energyBranch = EnergyBranch()
            energyBranch?.title = "title".localize(with: prefixEnergy)
            energyBranch?.branches = branches
        }
    }
    
    static func updateBranchData(in branch: EnergyBranch, with logData: [LogTag?], dateItem: EnergyDateItem) -> EnergyBranch {
        //支路在results中的起始序列
        var childOffset = 0
        if branch.isValidTag() {
            let values = logData[0]?.Values ?? []
            branch.energyData = BasicUtility.getEnergyData(values: values, dateItem: dateItem)
            childOffset = 1
        }
        for i in 0..<branch.branches.count {
            let values = logData[i + childOffset]?.Values ?? []
            let data = BasicUtility.getEnergyData(values: values, dateItem: dateItem)
            branch.branches[i].energyData = data
        }
        //
        if !branch.isValidTag() {
            let lastDatas = branch.branches.map { $0.energyData?.chartValues.first?.values ?? [] }
            let lastData = uniteBranchValues(values: lastDatas)
            let currentDatas = branch.branches.map { $0.energyData?.chartValues.last?.values ?? [] }
            let currentData = uniteBranchValues(values: currentDatas)
            let chartValues = [("last".localize(with: prefixEnergy), lastData), ("current".localize(with: prefixEnergy), currentData)]
            branch.energyData = EnergyData(dateItem, chartValues: chartValues)
        }
        return branch
    }
    
    /// 将从服务后台返回的数据转换为能耗分析模型
    /// - Parameter values: <#values description#>
    static func getEnergyData(values: [String], dateItem: EnergyDateItem) -> EnergyData {
        let doubleValues = filterAccumulatedValues(values: values)
        let unitedValues = uniteChartValues(values: doubleValues, dateItem: dateItem)
        let chartValues = separeteLinkValues(values: unitedValues, dateItem: dateItem)
        let data = EnergyData(dateItem, chartValues: chartValues)
        return data
    }
    
    /// 分离上一期和当前期的数据
    /// - Parameters:
    ///   - values: <#values description#>
    ///   - dateItem: <#dateItem description#>
    private static func separeteLinkValues(values: [Double], dateItem: EnergyDateItem) -> [(name: String, values: [Double])] {
        let records = dateItem.getLastPeriodRecords()
        var results = [(name: String, values: [Double])]()
        let lastValues = Array(values.prefix(records))
        let currentValues = Array(values.suffix(from: records))
        results.append(("last".localize(with: prefixEnergy), lastValues))
        results.append(("current".localize(with: prefixEnergy), currentValues))
        return results
    }
    
    
    /// 聚合数据用于图标显示
    /// - Parameters:
    ///   - values:
    ///   - dateItem: <#dateItem description#>
    private static func uniteChartValues(values: [Double], dateItem: EnergyDateItem) -> [Double] {
        if dateItem.dateType == .day {
            return values
        }
        if dateItem.dateType == .month {
            var results: [Double] = []
            //因月模式以小时为粒度，需整合为天数据
            for i in 0..<values.count where i % 24 == 0 {
                let startIndex = i
                let endIndex = (i + 24 < values.count) ? i + 24 : values.count
                results.append(values[startIndex..<endIndex].reduce(0, +).roundToPlaces(places: 0))
            }
            return results
        }
        
        //年模式，按月份天数合成
        var results: [Double] = []
        var date = dateItem.date - 1.years
        var startIndex = 0
        while startIndex < values.count {
            let monthDays = date.monthDays
            let endIndex = startIndex + monthDays < values.count ? startIndex + monthDays : values.count
            results.append(values[startIndex..<endIndex].reduce(0, +).roundToPlaces(places: 0))
            startIndex = endIndex
            date = date + 1.months
        }
        return results
    }
    
    /// 处理累加值
    /// - Parameter values: 需考虑到起始或中间因通讯中断造成的空值情况
    static func filterAccumulatedValues(values: [String]) -> [Double] {
        var results: [Double] = []
        //空值文本（#）转换为Float将为空值
        let floatValues: [Double?] = values.map { element in
            if let value=Double(element){
                //离线时value可能为-1 or
                //-65537(A*65536+B,其中A=B=-1),后一种情况为通行网关电能变量计算点处理，2020-05-26已经被优化，但是历史数据库还有遗留
                return value<=0 ? nil : value
            } else {
                return nil
            }
        }
        for index in 1..<floatValues.count {
            let subFloatValue = floatValues.prefix(index)
            //当前值不为空，前面还存在有效值，进行递减操作
            if let current = floatValues[index], let lastIndex = subFloatValue.lastIndex(where: { $0 != nil }) {
                //已排除last未空的项
                var deltaValue = current - subFloatValue[lastIndex]!
                //上面已经排除了通讯失败为0的值，若存在deltaValue为0，则出现电能被人为置零
                deltaValue = deltaValue < 0 ? current : deltaValue
                let avgValue = deltaValue / Double(index - lastIndex)
                //通讯中断的点，取这个区间的均值
                for i in (lastIndex + 1)..<index {
                    //采用递减，数目少一
                    results[i - 1] = avgValue
                }
                results.append(avgValue)
            } else {
                //空值设定为0
                results.append(0)
            }
        }
        return results
    }
    
    
    /// 主路自身没有值时，由支路累加而成
    /// - Parameter values: <#values description#>
    static func uniteBranchValues(values: [[Double]]) -> [Double] {
        var results = [Double]()
        if let count = values.first?.count {
            for i in 0..<count {
                results.append(0)
                for j in 0..<values.count {
                    results[i] = (results[i] + values[j][i]).roundToPlaces(places: 0)
                }
            }
        }
        return results
    }
    
}
