//
//  Workorder.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/13.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  运维工单

import Foundation
import HandyJSON

class Workorder: HandyJSON {
    
    static let icon = UIImage(systemName: "doc.richtext")
    static let description = "workorder".localize()

    //🆔，e.g.:1/XRD-20181010164444 (ProjectID-创建时间）
    var id: String = ""
    //执行状态
    var state: WorkorderState = .unCompleted
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

    required init() { }

    init(workorderID: String, title: String, startTime: Date, endTime: Date) {
        //创建工单必填项
        self.id = workorderID
        self.title = title
        self.start = startTime.toDateStartTimeString()
        self.end = endTime.toDateStartTimeString()
    }

}

//工单状态：未完成，已完成
enum WorkorderState: Int, HandyJSONEnum {
    case unCompleted = 0
    case completed = 1
}

//工单类型：计划任务，异常维护，随工追加，EDS系统工单
enum WorkorderType: Int, HandyJSONEnum {
    case plan = 0
    case alarm = 1
    case additional = 2
    case system = 3
}
