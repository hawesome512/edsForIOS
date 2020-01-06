//
//  DeviceCellType.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/24.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

enum DeviceCellType: String {

    //Device List=======================
    //静态，非通信型设备
    case fixed
    //设备动态状态，通信型设备
    case dynamic

    //Device Page Common================
    //柱状图
    case bar
    //按钮
    case button
    //开关,switch是系统关键字
    case onoff
    //水平范围条
    case range
    //大标题文字
    case text
    //可调参数
    case item
    //默认，文字，default是系统关键字
    case list

    //特殊定制============================
    //ATS类型设备工作状态显示单元
    case ATSStatus


    /// 获取表格Cell行高，默认使用屏幕占比ratio*height，分辨率小的情况下使用min
    func getRowHeight() -> (ratio: CGFloat, min: CGFloat) {
        switch self {
        case .bar, .ATSStatus:
            return (0.25, 240)
        case .dynamic, .text, .button, .range:
            return (0.125, 120)
        case .onoff, .fixed, .list, .item:
            return (0.0625, 60)
        }
    }


    /// 生成Cell
    func getTableCell() -> UITableViewCell {
        switch self {
        case .fixed:
            return DeviceFixedCell(style: .default, reuseIdentifier: rawValue)
        case .dynamic:
            return DeviceDynamicCell(style: .default, reuseIdentifier: rawValue)
        case .bar:
            return DeviceBarCell(style: .default, reuseIdentifier: rawValue)
        case .button:
            return DeviceButtonCell(style: .default, reuseIdentifier: rawValue)
        case .onoff:
            return DeviceOnOffCell(style: .default, reuseIdentifier: rawValue)
        case .range:
            return DeviceRangeCell(style: .default, reuseIdentifier: rawValue)
        case .text:
            return DeviceTextCell(style: .default, reuseIdentifier: rawValue)
        case .list, .item:
            return DeviceListCell(style: .default, reuseIdentifier: rawValue)
        case .ATSStatus:
            return DeviceATSStatusCell(style: .default, reuseIdentifier: rawValue)
        }
    }
}

