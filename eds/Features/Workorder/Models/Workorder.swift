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

class Workorder: HandyJSON {

    static let shortDate = "MMMdd"
    static let icon = UIImage(systemName: "doc.richtext")
    static let description = "workorder".localize()

    private let separator = ";"

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
    //运维地点
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

    required init() { }

    init(workorderID: String, title: String, startTime: Date, endTime: Date) {
        //创建工单必填项
        self.id = workorderID
        self.title = title
        self.start = startTime.toDateStartTimeString()
        self.end = endTime.toDateStartTimeString()
    }

    func getTimeRange() -> String {
        let startDate = start.toDate()?.toFormat(Workorder.shortDate) ?? ""
        let endDate = end.toDate()?.toFormat(Workorder.shortDate) ?? ""
        return "\(startDate) - \(endDate)"
    }

    func getTimeState() -> (icon: UIImage?, color: UIColor) {
        if state.rawValue >= WorkorderState.executed.rawValue {
            return (UIImage(systemName: "checkmark.circle.fill"), .systemGreen)
        }
        let nowTime = DateInRegion(Date(), region: .current)
        if let endTime = end.toDate(nil, region: .current), nowTime > endTime {
            return (UIImage(systemName: "bell.circle.fill"), .systemRed)
        }
        return (UIImage(systemName: "clock.fill"), .systemGray)
    }

    func getFlows() -> [WorkorderFlow] {
        return WorkorderState.allCases.map { WorkorderFlow(state: $0, workorder: self) }
    }

    func getMessages() -> [WorkorderMessage] {
        let messages = log.components(separatedBy: separator).map { WorkorderMessage.generate(with: $0) }
        return messages.filter { $0 != nil } as! [WorkorderMessage]
    }

    func getTasks() -> [WorkorderTask] {
        let tasks = task.components(separatedBy: separator).map { WorkorderTask.generate(with: $0) }
        return tasks.filter { $0 != nil } as! [WorkorderTask]
    }

    func getInfos() -> [WorkorderInfo] {
        return WorkorderInfo.generateInfos(with: self)
    }

    func getImageURLs() -> [URL] {
        //无图片
        if image.isEmpty {
            return [URL]()
        }
        return image.components(separatedBy: separator).map { $0.getEDSServletImageUrl() }
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
enum WorkorderType: Int, HandyJSONEnum {
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

