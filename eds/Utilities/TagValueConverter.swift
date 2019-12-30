//
//  TagValueConverter.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/25.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

class TagValueConverter {


    /// 转换设备状态信息
    /// - Parameters:
    ///   - value: 状态点值
    ///   - items: 开关位
    static func getStatus(value: Double, items: [String]) -> DeviceStatusType? {

        let intValue = Int(value)

        guard intValue >= 0 else {
            return DeviceStatusType.offline
        }

        //格式：过载/合闸/脱扣……
        var statusText = ""
        items.enumerated().forEach {
            //排除空值位
            if $0.element != DeviceModel.itemNil {
                //防止pow(x,y)👉decimal
                let flag = Int(pow(Double(2), Double($0.offset)))
                //0 or 1
                let indexValue = (intValue & flag) / flag
                //某些开关位0/1都有意义，如0👉分闸，1👉合闸，否则只添加1时点值
                let itemInfos = $0.element.components(separatedBy: DeviceModel.itemInfoSeparator)
                if itemInfos.count == 2 {
                    statusText.append(contentsOf: itemInfos[indexValue] + DeviceModel.itemInfoSeparator)
                } else if indexValue == 1 {
                    statusText.append(contentsOf: itemInfos[0] + DeviceModel.itemInfoSeparator)
                }
            }
        }
        //移除末尾标点符号
        statusText = statusText.trimmingCharacters(in: .punctuationCharacters)
        return DeviceStatusType(rawValue: statusText)
    }
}


/// 设备状态类型：类型，断电，上电（无异常），异常
enum DeviceStatusType: String {
    case offline
    case off
    case on
    case alarm

    func getStatusColor() -> UIColor {
        switch self {
        case .offline:
            return .systemGray
        case .on, .off:
            return UIColor.systemGreen.withAlphaComponent(0)
        case .alarm:
            return .systemYellow
        }
    }

    func getStatusText() -> String {
        switch self {
        case .offline:
            return NSLocalizedString("离线", comment: "device_offline")
        case .off:
            return NSLocalizedString("OFF", comment: "device_off")
        case .on:
            return NSLocalizedString("ON", comment: "device_on")
        case .alarm:
            return NSLocalizedString("异常", comment: "device_alarm")
        }
    }
}
