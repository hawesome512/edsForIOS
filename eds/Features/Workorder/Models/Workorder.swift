//
//  Workorder.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/13.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  运维工单

import Foundation
import HandyJSON
import SwiftDate

class Workorder: HandyJSON, Comparable {


    static let icon = UIImage(systemName: "doc.richtext")
    static let description = "workorder".localize()
    //允许上传的图片数量限制
    static let imageLimit = 12

    private let separator = ";"

    //是否是新增工单，新增工单增加角标
    var added = false

// MARK: -EDSService

    //🆔，e.g.:1/XRD-20181010164444 (ProjectID-创建时间）
    var id: String = ""
    //执行状态
    var state: WorkorderState = .created
    //工单类型
    var type: WorkorderType = .plan
    //任务标题
    var title: String = ""
    //执行任务，e.g.:A task;B task……（使用分号；分割任务点)
    var task: String = ""
    //计划执行起始时间，e.g.:2019-10-01 00:00:00
    var start: String = ""
    //计划执行截止时间，e.g.:2019-10-01 00:00:00
    var end: String = ""
    //资产范围
    var location: String = ""
    //执行指定责任人，e.g.:hs-18734831111(名字-电话）
    var worker: String = ""
    //工单日志，e.g.:A task;B task……（使用分号；分割任务点)
    var log: String = ""
    //现场图片资料，e.g.:A.jpg;B.jpg……（使用分号；分割任务点)
    var image: String = ""
    //创建人，当前登录用户
    var creator: String = ""
    //流程，e.g.:0_2019-05-23 12:00:00_徐海生;1_2019-05-23 12:00:00;……
    var flow: String = ""
    //审核人
    var auditor: String = ""
    
    //工单的时间状态，初始化是未判定
    private var flowTimeLine: FlowTimeLine = .none

    required init() { }

    func getTimeRange() -> String {
        let startDate = start.toDate(nil, region: .local)?.date.toDateString() ?? ""
        let endDate = end.toDate(nil, region: .local)?.date.toDateString() ?? ""
        return String(format: "time_range".localize(with: prefixWorkorder), startDate, endDate)
    }

    func getShortTimeRange() -> String {
        let startDate = start.toDate(nil, region: .local)?.date.toShortDateString() ?? ""
        let endDate = end.toDate(nil, region: .local)?.date.toShortDateString() ?? ""
        return String(format: "time_range".localize(with: prefixWorkorder), startDate, endDate)
    }

    func getFlowTimeLine() -> FlowTimeLine {
        //从后台数据库获取时并无时间状态
        if flowTimeLine == .none {
            updateFlowTimeLine()
        }
        return flowTimeLine
    }
    
    private func updateFlowTimeLine(){
        //工单状态改变时需及时更新时间状态
        if state.rawValue >= WorkorderState.executed.rawValue {
            flowTimeLine = .done//(UIImage(systemName: "checkmark.circle.fill"), .systemGreen)
            return
        }
        let nowTime = DateInRegion(Date(), region: .local)
        if let endTime = end.toDate(nil, region: .local), nowTime > endTime {
            flowTimeLine = .overdue//(UIImage(systemName: "bell.circle.fill"), .systemRed)
            return
        }
        flowTimeLine = .planing//(UIImage(systemName: "clock.fill"), .systemGray)
    }

    func getFlows() -> [WorkorderFlow] {
        return WorkorderState.allCases.map { WorkorderFlow(state: $0, workorder: self) }
    }

    func getMessages() -> [WorkorderMessage] {
        let messages = log.components(separatedBy: separator).map { WorkorderMessage.decode(with: $0) }
        return messages.filter { $0 != nil } as! [WorkorderMessage]
    }

    func setMessage(_ messages: [WorkorderMessage]) {
        log = messages.map { $0.toString() }.joined(separator: separator)
    }

    func getTasks() -> [WorkorderTask] {
        let tasks = task.components(separatedBy: separator).map { WorkorderTask.generate(with: $0) }
        return tasks.filter { $0 != nil } as! [WorkorderTask]
    }

    func setTasks(titles: [String]) {
        task = titles.map { WorkorderTask(title: $0).toString() }.joined(separator: separator)
    }

    func setTasks(_ tasks: [WorkorderTask]) {
        task = tasks.map { $0.toString() }.joined(separator: separator)
    }

    func getInfos() -> [WorkorderInfo] {
        return WorkorderInfo.generateInfos(with: self)
    }
    
    func getDeviceTitles() -> [String] {
        return location.components(separatedBy: separator)
    }

    func setImages(_ images: [String]) {
        image = images.joined(separator: separator)
    }

    func getImageURLs() -> [String] {
        //无图片
        if image.isEmpty {
            return [String]()
        }
        return image.components(separatedBy: separator)
    }

    func setState(with newState: WorkorderState, by name: String) {
        //流程不能回退，避免此情况：已经执行了，工单再被派发
        let newFlow = WorkorderFlow.toFormat(state: newState, name: name)
        if newState.rawValue > state.rawValue {
            flow += separator + newFlow
        } else if newState.rawValue == state.rawValue {
            var temps = flow.components(separatedBy: separator)
            temps[temps.count - 1] = newFlow
            flow = temps.joined(separator: separator)
        }
        state = newState
        //更新时间状态
        updateFlowTimeLine()
    }

    func prepareSaved() -> Bool {
        //核对必要信息是否完善
        let nessary = [id, title, task, start, end, worker, auditor]
        return !nessary.contains { $0.isEmpty }
    }

    func prepareDeleted() {
        title = ""
    }

    // MARK: - 工单权重
    //权重系数,满分100，值越大越相关，用于排序跟当前用户最相关的工单，显示在首页中：
    //工单状态因子（30）：已审核-10，已执行-10，已派发-10，已完成的工单因子为0
    //截止时间因子（40）：限定±1月，设定day=now-截止，-day*2/30 或 -day/30
    //关联因子（30）：本人创建+10，执行+10，审核+10
    func calWeightCoefficient(with accountName: String? = nil) -> Int {
        var factor: Int = 100
        factor = factor - state.rawValue * 10
        if let name = accountName, !name.isEmpty {
            let rolers = [creator, worker, auditor].filter { $0 != name }
            factor = factor - rolers.count * 10
        }
        if let endDate = end.toDate(nil, region: .local) {
            if let deltaDay = (DateInRegion(Date(), region: .current) - endDate).toUnit(.day) {
                //截止日期已经过期的权重更大,截止日期离得近的（deltaDay越小）权重更大
                let ratio: Double = deltaDay > 0 ? 1 : 2
                //ratio(:2)*20=满级权重（40），±1月（30）
                let dateFactor = min(Double(abs(deltaDay)), 30) / 30 * ratio * 20
                factor = factor - Int(dateFactor)
            }
        }
        return factor
    }


    // MARK: -工单列表排序
    static func < (lhs: Workorder, rhs: Workorder) -> Bool {
        if let left = lhs.start.toDate(nil, region: .local), let right = rhs.start.toDate(nil, region: .local) {
            return left.isBeforeDate(right, granularity: .second)
        }
        return true
    }

    static func == (lhs: Workorder, rhs: Workorder) -> Bool {
        return lhs.id == rhs.id
//        return lhs.start == rhs.start
    }

}

//工单状态：创建，派发，执行，审核，实现CI协议方便遍历
enum WorkorderState: Int, HandyJSONEnum, CaseIterable {
    case created = 0
    case distributed = 1
    case executed = 2
    case audited = 3

    func getText() -> String {
        return "\(self)".localize(with: prefixWorkorder)
    }
}

//工单类型：计划任务，异常维护，随工追加，EDS系统工单
enum WorkorderType: Int, HandyJSONEnum, CaseIterable {
    case plan = 0
    case alarm = 1
    case additional = 2
    case system = 3

    func getColor() -> UIColor {
        switch self {
        case .plan:
            return .systemBlue
        case .alarm:
            return .systemRed
        case .additional:
            return .systemGreen
        default:
            return .systemGray
        }
    }

    func getText() -> String {
        return "\(self)".localize(with: prefixWorkorder)
    }
}

