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

    private var tagList: [Tag] = [] {
        didSet {
            //获取点列表之后，进行mqtt订阅
            MQTTService.sharedInstance.delegate = self
            MQTTService.sharedInstance.refreshTagValues(projectName: tempProject)
        }
    }

    //MARK:通信>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    //临时测试，public，其他页面（修改参数）也可以调用
    public let tempAuthority = "guest:xseec".toBase64()
    public let tempProjectID = "2/XRD"
    public let tempProject = "XRD"

    /// 从后台导入工程点列表
    func loadProjectTagList() {
        //获取后台服务点列表请求在生命周期中只有一次
        guard tagList.count == 0 else {
            return
        }
        MoyaProvider<WAService>().request(.getTagList(authority: tempAuthority, projectID: tempProjectID)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[tag?]?👉[tag]
                let tempList = JsonUtility.getTagList(data: response.data)
                self.tagList = (tempList?.filter { $0 != nil })! as! [Tag]
                self.updateTagList(with: self.tagList)
                print("TagUtility:Load project tag list.")
            default:
                break
            }
        }
    }

    /// 更新点值
    /// - Parameter tags: 需要更新的点列表
    func updateTagList(with tags: [Tag]) {
        guard tags.count > 0 else {
            return
        }
        MoyaProvider<WAService>().request(.getTagValues(authority: tempAuthority, tagList: tags)) { result in
            switch result {
            case .success(let response):
                self.update(with: JsonUtility.getTagValues(data: response.data))
                print("TagUtility:Update \(tags.count) tag values.")
            default:
                break
            }
        }
    }

    func didReceiveMessage(mqtt: CocoaMQTT, message: CocoaMQTTMessage, flag: UInt16) {
        update(with: JsonUtility.getMQTTTagList(message: message))
        //print("Mqtt receive at " + Date().description)
    }


    //MARK:便捷方法>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    /// 获取设备中的点列表（可空）
    /// - Parameters:
    ///   - tagNames: 点（短）名称：[Ia,Ib……]
    ///   - device: 设备名:KB_A3_1
    func getTagList(by tagNames: [String], in device: String) -> [Tag] {
        //经过filter后已排除nil项，可以安全使用as!
        return tagNames.map { name in
            tagList.first { $0.Name == device + Tag.nameSeparator + name }
        }.filter { $0 != nil } as! [Tag]
    }


    /// 根据点名称，获取关联点（related)所属设备中的点
    /// - Parameters:
    ///   - tagName: 点名称
    ///   - tag: 关联点
    func getRelatedTag(with tagName: String, related tag: Tag) -> Tag? {
        //tag.Name:KB_A3_1:Ia
        let device = tag.Name.components(separatedBy: Tag.nameSeparator)[0]
        return tagList.first { $0.Name == device + Tag.nameSeparator + tagName }
    }

    //MARK:私有方法>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    //MARK:静态方法>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// 获取设备类型图标
    /// - Parameter name: 设备or点名称，CY_A2_2👉A2
    static func getDeviceIcon(with name: String) -> UIImage? {
        let infos = name.components(separatedBy: Tag.deviceSeparator)
        return infos.count == 3 ? UIImage(named: "device_" + infos[1]) : nil
    }


    /// 获取设备类型String
    /// - Parameter name: 设备or点名称
    static func getDeviceType(with name: String) -> String? {
        let infos = name.components(separatedBy: Tag.deviceSeparator)
        return infos.count == 3 ? infos[1] : nil
    }

    /// 获取设备名String
    /// - Parameter name: 设备or点名称
    static func getDeviceName(with name: String) -> String? {
        let infos = name.components(separatedBy: Tag.nameSeparator)
        return infos.count == 2 ? infos[0] : nil
    }
}
