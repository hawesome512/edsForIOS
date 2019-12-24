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
    //静态，非通信型设备
    case DeviceStaticCell
    //设备动态状态，通信型设备
    case DeviceDynamicCell
    //ATS类型设备工作状态显示单元
    case DeviceATSStatusCell
    //柱状图
    case DeviceBarCell
    //按钮
    case DeviceButtonCell
    //开关
    case DeviceOnOffCell
    //水平范围条
    case DeviceRangeCell
    //大标题文字
    case DeviceTextCell
    //默认，文字
    case DeviceDefaultCell

    /// 获取表格Cell行高，默认使用屏幕占比ratio*height，分辨率小的情况下使用min
    func getRowHeight() -> (ratio: CGFloat, min: CGFloat) {
        switch self {
        case .DeviceBarCell, .DeviceATSStatusCell:
            return (0.25, 240)
        case .DeviceDynamicCell, .DeviceTextCell, .DeviceButtonCell, .DeviceRangeCell:
            return (0.125, 120)
        case .DeviceOnOffCell, .DeviceStaticCell, .DeviceDefaultCell:
            return (0.0625, 60)
        }
    }
}
