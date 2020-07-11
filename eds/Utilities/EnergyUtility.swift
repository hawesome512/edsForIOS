//
//  EnergyUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import RxCocoa
import SwiftDate

class EnergyUtility {
    static let sharedInstance = EnergyUtility()
    
    private(set) var energy: Energy?
    private var energyBranch: EnergyBranch?
    private(set) var successfulUpdated = BehaviorRelay<Bool>(value: false)
    
    private(set) var accountEnergyList: [Energy] = []
    private(set) var accountEnergyBranchList: [EnergyBranch?] = []
    private(set) var successfulAccountsUpdated = BehaviorRelay<Bool>(value: false)
    
    private init () { }
    
    func loadProjectEnergy() {
        guard let projID = AccountUtility.sharedInstance.account?.id else { return }
        
        //因为用户id的格式为数字/工程名，使用id="/"将获取所有账户，e.g.:2/XRD、1/XKB
        let factor = EDSServiceQueryFactor(id: "/")//projID)
        EDSService.getProvider().request( .queryEnergyList(factor: factor)) { result in
            switch(result) {
            case .success(let response):
                guard let temps = JsonUtility.getEDSServiceList(with: response.data, type: [Energy]())  else { return }
                self.accountEnergyList = (temps.filter { $0 != nil } as! [Energy])
                guard let temp = self.accountEnergyList.first(where: { $0.id == projID }) else { return }
                self.energy = temp
                self.loadProjectEnergyData()
            default:
                break
            }
        }
    }
    
    private func loadProjectEnergyData() {
        guard let authority = AccountUtility.sharedInstance.account?.authority else { return }
        guard let energy = energy else { return }
        energyBranch = initBranch(branchInfo: energy.branch)
        guard let energyBranch = energyBranch else { return }
        
        let logTags = energyBranch.getLogTags()
        let date = DateInRegion(Date(), region: .current).dateAtStartOf(.month)
        let dateItem = EnergyDateItem(date, type: .month)
        let condition = dateItem.getLogRequestCondition(with: logTags)
        WAService.getProvider().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let results = JsonUtility.getTagLogValues(data: response.data) ?? []
                //获得完整数据
                guard results.count == logTags.count else { return }
                let _ = EnergyUtility.updateBranchData(in: energyBranch, with: results, dateItem: dateItem)
                self.successfulUpdated.accept(true)
                print("loaded project energy data")
                break
            default:
                self.successfulUpdated.accept(false)
            }
        }
    }
    
    /// 获取所有用户的顶级用电信息，用于横向比较
    func loadAccountsEnergyData() {
        guard accountEnergyBranchList.count == 0 else { return }
        guard let authority = AccountUtility.sharedInstance.account?.authority else { return }
        accountEnergyBranchList = accountEnergyList.map{ initBranch(branchInfo: $0.branch) }
        var logTags: [LogTag] = []
        accountEnergyBranchList.forEach{ logTags += $0?.getLogTags() ?? [] }
        let date = DateInRegion(Date(), region: .current).dateAtStartOf(.month)
        let dateItem = EnergyDateItem(date, type: .month)
        let condition = dateItem.getLogRequestCondition(with: logTags)
        WAService.getProvider().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let results = JsonUtility.getTagLogValues(data: response.data) ?? []
                //获得完整数据
                guard results.count == logTags.count else { return }
                self.accountEnergyBranchList.forEach{
                    if let tempLogTags = $0?.getLogTags() {
                        let itemLogTags = results.filter{ tempLogTags.contains($0!) }
                        let _ = EnergyUtility.updateBranchData(in: $0!, with: itemLogTags, dateItem: dateItem)
                    }
                }
                self.successfulAccountsUpdated.accept(true)
                print("loaded all accounts project energy data")
                break
            default:
                self.successfulAccountsUpdated.accept(false)
            }
        }
        
    }
    
    func updateEnergy() {
        guard let energy = energy else { return }
        EDSService.getProvider().request(.updateEnergy(energy: energy)){_ in }
        ActionUtility.sharedInstance.addAction(.editBranch)
        successfulUpdated.accept(true)
    }
    
    /// 退出前清空资源
    func clearEnergy(){
        energy = nil
        successfulUpdated.accept(false)
        accountEnergyBranchList = []
        successfulAccountsUpdated.accept(false)
    }
    
    func getEnergyBranch() -> EnergyBranch?{
        if energyBranch==nil,!successfulUpdated.value {
            loadProjectEnergyData()
        }
        return energyBranch
    }
    
    // MARK: - 用电支路
    
    
    /// 初始化用户的用电支路
    /// - Parameter branchInfo: 用户支路文本
    /// - Returns: <#description#>
    private func initBranch(branchInfo: String) -> EnergyBranch? {
        let branches = EnergyBranch.getLevelBranches(branchInfo)
        switch branches.count {
        case 0:
            return nil
        case 1:
            return branches[0]
        default:
            //若第1⃣️级支路超过1个，另设顶级支路，以所有第1⃣️级支路值为其支路
            let energyBranch = EnergyBranch()
            energyBranch.title = "title".localize(with: prefixEnergy)
            energyBranch.branches = branches
            return energyBranch
        }
    }
    
    static func updateBranchData(in branch: EnergyBranch, with logData: [LogTag?], dateItem: EnergyDateItem) -> EnergyBranch {
        //支路在results中的起始序列
        var childOffset = 0
        if branch.isValidTag() {
            let values = logData[0]?.Values ?? []
            branch.energyData = EnergyUtility.getEnergyData(values: values, dateItem: dateItem)
            childOffset = 1
        }
        for i in 0..<branch.branches.count {
            let values = logData[i + childOffset]?.Values ?? []
            let data = EnergyUtility.getEnergyData(values: values, dateItem: dateItem)
            branch.branches[i].energyData = data
        }
        //
        if !branch.isValidTag() {
            let lastDatas = branch.branches.map { $0.energyData?.chartValues.first?.values ?? [] }
            let lastData = uniteBranchValues(values: lastDatas)
            let currentDatas = branch.branches.map { $0.energyData?.chartValues.last?.values ?? [] }
            let currentData = uniteBranchValues(values: currentDatas)
            let chartValues = [("last".localize(with: prefixEnergy), lastData), ("current".localize(with: prefixEnergy), currentData)]
            let dbValues = branch.branches.map{$0.energyData?.doubleValues ?? []}
            let doubleValues = uniteBranchValues(values: dbValues)
            branch.energyData = EnergyData(dateItem, chartValues: chartValues,doubleValues: doubleValues)
        }
        return branch
    }
    
    /// 将从服务后台返回的数据转换为能耗分析模型
    /// - Parameter values: <#values description#>
    static func getEnergyData(values: [String], dateItem: EnergyDateItem) -> EnergyData {
        let doubleValues = filterAccumulatedValues(values: values)
        let unitedValues = uniteChartValues(values: doubleValues, dateItem: dateItem)
        let chartValues = separeteLinkValues(values: unitedValues, dateItem: dateItem)
        let data = EnergyData(dateItem, chartValues: chartValues, doubleValues: doubleValues)
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
                results.append(values[startIndex..<endIndex].reduce(0, +).roundToPlaces(fractions: 0))
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
            results.append(values[startIndex..<endIndex].reduce(0, +).roundToPlaces(fractions: 0))
            startIndex = endIndex
            date = date + 1.months
        }
        return results
    }
    
    /// 处理累加值
    /// - Parameter values: 需考虑到起始或中间因通讯中断造成的空值情况
    static func filterAccumulatedValues(values: [String]) -> [Double] {
        var results: [Double] = []
        //通信异常：文本（#/-n）转换为Float将为空值
        let floatValues: [Double?] = values.map { element in
            if let value=Double(element){
                return value<=0 ? nil : value
            } else {
                return nil
            }
        }
        for index in 1..<floatValues.count {
            let subFloatValue = floatValues.prefix(index)
            //当前值不为空，前面还存在有效值，进行递减操作
            guard let current = floatValues[index], let lastIndex = subFloatValue.lastIndex(where: { $0 != nil }) else {
                results.append(0)
                continue
            }
            
            // FIXME: 目前尚发现两种deltaValue≤0的情况：总无功电能夜间在机台为工作时方向输出或电能被人为置零（此时应当deltaValue=current更为合理）
            //通讯中断的点，取这个区间的均值,e.g: V1=10,V2=nil,V3=nil,V4=40 ➡️ V21=V32=V43=(40-10)/3=10
            let deltaValue = current - subFloatValue[lastIndex]!
            let avgValue = deltaValue / Double(index - lastIndex)
            for i in (lastIndex + 1)..<index {
                results[i - 1] = avgValue
            }
            results.append(avgValue)
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
                    results[i] = (results[i] + values[j][i]).roundToPlaces(fractions: 0)
                }
            }
        }
        return results
    }
    
    
    /// 统计尖峰平谷数据，计算模型见于Energy.class
    /// - Parameters:
    ///   - energy: <#energy description#>
    ///   - data: <#data description#>
    /// - Returns: <#description#>
    static func calTimeDatas(energy: Energy, data: EnergyData) -> [TimeData] {
        let curDoubleValues = data.getCurrentDoubleValues()
        let hoursDic = energy.getHourDic()
        let timeDatas = energy.getTimeData()
        curDoubleValues.enumerated().forEach { (offset, element) in
            let date = data.dateItem.date + offset.hours
            let index1 = hoursDic[date.hour * 2]?.rawValue ?? 0
            timeDatas[index1].totalValue += element/2
            let index2 = hoursDic[date.hour * 2 + 1]?.rawValue ?? 0
            timeDatas[index2].totalValue += element/2
        }
        return timeDatas
    }
    
    /// 平衡分时用电占比的显示效果，避免太小占比过分压缩文本
    /// - Parameters:
    ///   - ratios: <#ratios description#>
    ///   - min: 最小阈值
    /// - Returns: <#description#>
    static func balancedShowRatio(with ratios: [Double], min: Double = 0.12) -> [Double] {
        var newRatios = ratios.map { ($0 > 0 && $0 < min) ? min : $0 }
        //填补最小（非0）值多出部分由其他区段按比例分摊
        let delta = newRatios.reduce(0, +) - ratios.reduce(0, +)
        let otherSum = ratios.filter{ $0 > min}.reduce(0, +)
        newRatios = newRatios.map{ ($0 > min) ? $0 - $0/otherSum * delta : $0 }
        return newRatios
    }
}
