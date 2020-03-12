//
//  Alarm.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/14.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  系统异常记录

import Foundation
import HandyJSON

class Alarm: HandyJSON, EDSDelegate {

    static let icon = UIImage(systemName: "bell")
    static let description = "alarm".localize()

    //🆔，e.g.:1/XRD-20191001121212(ProjectID-时间戳）
    var id = ""
    //异常设备，e.g.：CY_A2_2
    var device = ""
    //异常类型，e.g.：异常[1](数字即为相应设备的异常编码，具体见于通讯约定）
    var alarm = ""
    //异常发生时间，e.g.：2019-10-01 12:12:12
    var time = ""
    //异常是否已排查处理，0:未处理/1:已确认
    var confirm = AlarmConfirm.unchecked
    //异常排查报告，即异常工单ID
    var report = ""

    required init() { }

    //异常记录由服务器生成,仅用于调试
    init(alarmID: String) {
        id = alarmID
    }

    func prepareForDelete() {
        alarm = ""
    }
}

//异常状态：未处理/已处理（将产生异常工单）
enum AlarmConfirm: Int, HandyJSONEnum {
    case unchecked = 0
    case checked = 1

    func getConfirmColor() -> UIColor {
        return self == AlarmConfirm.checked ? UIColor.systemGreen : UIColor.systemRed
    }
}
