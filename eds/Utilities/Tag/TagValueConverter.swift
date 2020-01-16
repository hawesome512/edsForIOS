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
    static func getText(value: Double, items: [String]?) -> (status: DeviceStatusType?, text: String) {

        if let items = items, items.count > 0 {
            //因为异常时需返回详情信息，无法使用rawValue，增加text状态文本
            let intValue = Int(value)
            //通信失败（离线）时value=Tag.nilValue=-1
            guard intValue >= 0 else {
                let status = DeviceStatusType.offline
                return (status, status.getStatusText())
            }

            //格式：将状态值intValue与开关位与（&）运算，判断状态详情，过载/短路/瞬时/（空值位）/合分闸/脱扣/（空值位）/……
            var statusText = ""
            items.enumerated().forEach {
                //排除空值位
                if $0.element != DeviceModel.itemNil {
                    //防止pow(x,y)👉decimal，2^n
                    let flag = intPow(x: 2, y: $0.offset)
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
            //移除末尾标点符号DeviceModel.itemInfoSeparator/
            statusText = statusText.trimmingCharacters(in: .punctuationCharacters)
            //alarm使用rawValue为nil,返回详情
            if statusText.isEmpty {
                //有些设备如ATS无ON/OFF,只有正常异常状态
                return (DeviceStatusType.normal, DeviceStatusType.normal.getStatusText())
            }
            let status = DeviceStatusType(rawValue: statusText) ?? DeviceStatusType.alarm
            //异常时返回详情信息
            let text = status == .alarm ? getLocalizedAlarmStatusText(statusText) : status.getStatusText()
            return (status, text)
        } else {
            //无效items时，不转换，直接显示数值

            return (nil, value.clean)
        }
    }


    /// 异常详情本地化文本
    /// - Parameter statusText: <#statusText description#>
    private static func getLocalizedAlarmStatusText(_ statusText: String) -> String {
        var status = ""
        statusText.components(separatedBy: DeviceModel.itemInfoSeparator).forEach {
            status.append($0.localize(with: prefixDevice) + " ")
        }
        return status
    }

    /// 获取固定值
    /// - Parameters:
    ///   - value: 数值
    ///   - items: 映射表["0","零“，”1“，”一“]
    static func getFixedText(value: Double, items: [String]?) -> String {
        let strValue = value.clean
        if let items = items, let index = items.firstIndex(of: strValue), index < items.count - 1 {
            return items[index + 1]
        }
        return strValue
    }

    /// 判断开关位是否为on（1）
    /// - Parameters:
    ///   - value: 点值
    ///   - items: ["0/off/on"]，其中off/on为可选，方便定制显示
    static func getSwitch(value: Double, items: [String]?) -> Bool {
        if let intIndex = getFirstInt(from: items) {
            let intValue = Int(value)
            //防止pow(x,y)👉decimal，2^n，使pow(double,double)
            let flag = intPow(x: 2, y: intIndex)
            return (intValue & flag) == flag
        } else {
            return false
        }
    }

    static func setSwitch(tagValue: String?, isOn: Bool, items: [String]?) -> String? {
        if let tagValue = tagValue, let dValue = Double(tagValue), let intIndex = getFirstInt(from: items) {
            let intValue = Int(dValue)
            if isOn {
                //或运算2^n，将标志位置1
                return String(intValue | intPow(x: 2, y: intIndex))
            } else {
                //与运算2^16-1-2^n，将标志位置0，开关位两个字节，最多16位,e.g.:n=3👉0x1111 0111
                return String(intValue & (intPow(x: 2, y: 16) - 1 - intPow(x: 2, y: intIndex)))
            }
        }
        return nil
    }


    /// 获取items中首项整数
    /// - Parameter items: ["0/false/true"]
    private static func getFirstInt(from items: [String]?) -> Int? {
        guard let item = items?.first else {
            return nil
        }
        return Int(item.components(separatedBy: DeviceModel.itemInfoSeparator)[0])
    }

    private static func intPow(x: Int, y: Int) -> Int {
        return Int(pow(Double(x), Double(y)))
    }
}

/// 设备状态类型：类型，断电，上电（无异常），异常
enum DeviceStatusType: String {
    case offline
    case off
    case on
    case normal
    case alarm

    func getStatusColor() -> UIColor {
        switch self {
        case .offline:
            return .systemGray
        case .on:
            return .systemRed
        case .off, .normal:
            return .systemGreen
        case .alarm:
            return .systemYellow
        }
    }

    func getStatusText() -> String {
        switch self {
        case .offline:
            return "offline".localize(with: "device")
        case .off:
            return "off".localize(with: "device")
        case .on:
            return "on".localize(with: "device")
        case .alarm:
            return "alarm".localize(with: "device")
        case .normal:
            return "normal".localize(with: "device")
        }
    }
}
