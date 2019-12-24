//
//  TagUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/20.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  监控点列表的处理，在此类单例中实现所有点处理操作
//  获取工程点列表（1次），获取所有点的值（1次），更新点点值（mqtt实时）

import Foundation
import Moya
import CocoaMQTT

class TagUtility: MQTTServiceDelegate {

    //单例，只允许存在一个实例
    static let sharedInstance = TagUtility()

    private init() { }

    var tagList: [Tag] = []

    /// 添加工程点列表，保持值单例中
    /// - Parameter target: target两个可空属性需要换算
    func addTagList(with target: [Tag?]?) {
        //获取后台服务点列表请求在生命周期中只有一次
        guard tagList.count == 0 else {
            return
        }
        tagList = (target?.filter { $0 != nil })! as! [Tag]
        print("TagUtility:Load project tag list.")

        //获取所有tag的value一次
        MoyaProvider<WAService>().request(.getTagValues(authority: "xkb:xseec".toBase64(), tagList: tagList)) { result in
            switch result {
            case .success(let response):
                self.update(with: JsonUtility.getTagValues(data: response.data))
                print("TagUtility:Update tag list value.")
            default:
                break
            }
        }

        //mqtt订阅
        //⚠️待验证订阅不会漏掉所有tag的value变化
        MQTTService.sharedInstance.delegate = self
        MQTTService.sharedInstance.refreshTagValues(projectName: "XKB")
    }

    func didReceiveMessage(mqtt: CocoaMQTT, message: CocoaMQTTMessage, flag: UInt16) {
        update(with: JsonUtility.getMQTTTagList(message: message))
        //print("Mqtt receive at " + Date().description)
    }


    /// 获取设备列表（淡化设备概念，用[String]
    func getDeviceList() -> [String] {
        var deviceNames: [String] = []
        tagList.forEach { tag in
            if !deviceNames.contains(tag.getDeviceName()) {
                deviceNames.append(tag.getDeviceName())
            }
        }
        return deviceNames
    }

    /// 获取设备点列表
    /// - Parameter deviceName: 设备名，“KB_A3_1”
    func getDeviceTagList(by deviceName: String) -> [Tag] {
        return tagList.filter { $0.Name.contains(deviceName) }
    }


    /// 获取点（可空）
    /// - Parameter tagName: 点名称
    func getTag(by tagName: String) -> Tag? {
        return tagList.first { $0.Name == tagName }
    }

    private func update(with target: [Tag?]?) {
        //Filter>forEach>first
        target?.forEach { tag in
            if let sourceTag = tagList.first(where: { $0.Name == tag?.Name }) {
                sourceTag.Value = tag?.Value
            }
        }
    }

    private func update(with target: [MQTTTag?]?) {
        let targetTags = target?.map { $0?.toTag() }
        update(with: targetTags)
    }

    //MARK:静态方法


    /// 获取设备类型图
    /// - Parameter name: 设备or点名称，CY_A2_2👉A2
    static func getDeviceIcon(with name: String) -> UIImage? {
        let infos = name.components(separatedBy: "_")
        return infos.count == 3 ? UIImage(named: "device_"+infos[1]) : nil
    }
}
