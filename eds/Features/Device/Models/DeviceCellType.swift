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

    //Fixed Page===========================
    //一般信息
    case info
    //二维码
    case qrcode
    //工单、异常指令
    case goto

    //特殊定制============================
    //ATS类型设备工作状态显示单元
    case ATSStatus


    /// 获取表格Cell行高，默认使用屏幕占比ratio*height，分辨率小的情况下使用min
    func getRowHeight(in tableView: UITableView) -> CGFloat {
        let height = tableView.frame.height
        switch self {
        case .bar, .ATSStatus, .qrcode:
            return max(0.25 * height, 240)
        case .text, .button, .range, .goto:
            return max(0.125 * height, 120)
        case .onoff, .list, .item, .dynamic, .fixed, .info:
            return max(0.0625 * height, 60)
        }
    }


    /// 生成Cell
    func getTableCell(parentVC: UIViewController?) -> UITableViewCell {
        switch self {
        case .fixed:
            return DeviceFixedCell(style: .default, reuseIdentifier: rawValue)
        case .dynamic:
            return DeviceDynamicCell(style: .default, reuseIdentifier: rawValue)
        case .bar:
            let cell = DeviceBarCell(style: .default, reuseIdentifier: rawValue)
            cell.parentVC = parentVC
            return cell
        case .button:
            let cell = DeviceButtonCell(style: .default, reuseIdentifier: rawValue)
            cell.parentVC = parentVC
            return cell
        case .onoff:
            let cell = DeviceOnOffCell(style: .default, reuseIdentifier: rawValue)
            cell.parentVC = parentVC
            return cell
        case .range:
            let cell = DeviceRangeCell(style: .default, reuseIdentifier: rawValue)
            cell.parentVC = parentVC
            return cell
        case .text:
            return DeviceTextCell(style: .default, reuseIdentifier: rawValue)
        case .list, .item:
            let cell = DeviceListCell(style: .default, reuseIdentifier: rawValue)
            cell.parentVC = parentVC
            return cell
        case .ATSStatus:
            return DeviceATSStatusCell(style: .default, reuseIdentifier: rawValue)
        case .qrcode:
            return FixedQRCodeCell(style: .default, reuseIdentifier: rawValue)
        case .goto:
            return FixedGotoCell(style: .default, reuseIdentifier: rawValue)
        case .info:
            return FixedInfoCell(style: .default, reuseIdentifier: rawValue)
        }
    }
}

