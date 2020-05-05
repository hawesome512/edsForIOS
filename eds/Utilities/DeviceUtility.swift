//
//  DeviceUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import RxCocoa

class DeviceUtility {

    //通过单列调取资产设备列表设备
    var deviceList: [Device] = []
    //单例，只允许存在一个实例
    static let sharedInstance = DeviceUtility()
    var successfulLoaded = BehaviorRelay<Bool>(value: false)

    private init() { }

    /// 从后台导入资产设备列表
    func loadProjectDeviceList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard deviceList.count == 0, let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        let factor = EDSServiceQueryFactor(id: projID)
        MoyaProvider<EDSService>().request(.queryDeviceList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[tag?]?👉[tag]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Device]())
                self.deviceList = (tempList?.filter { $0 != nil })! as! [Device]
                self.successfulLoaded.accept(true)
                print("TagUtility:Load project device list.")
            default:
                break
            }
        }
    }

    func remove(devices: [Device]) {
        deviceList = deviceList.filter { device in !devices.contains(device) }
    }

    func getDevice(of shortID: String) -> Device? {
        return deviceList.first { $0.getShortID() == shortID }
    }

    func getRalatedDevices(deviceNames: [String]) -> [Device] {
        return deviceList.filter { deviceNames.contains($0.getShortID()) }
    }


    /// 获取工程资产树
    /// - Parameter visiableOnly: 默认折叠
    /// - Parameter sources: 除了获取工程的资产树（sources=nil）以外，首页有显示非通讯型设备（other)的需求，此时sources为所有非通讯型资产设备
    func getProjDeviceList(visiableOnly: Bool = true, sources: [Device]? = nil) -> [Device] {
        var result: [Device] = []
        let devices = (sources == nil || sources!.count == 0) ? deviceList : sources!
        devices.filter { $0.level == .room }.forEach {
            result.append($0)
            result.append(contentsOf: getBranceList(device: $0, visiableOnly: visiableOnly, sources: devices))
        }
        return result
    }

    func getBranceList(device: Device, visiableOnly visiable: Bool, sources: [Device]? = nil) -> [Device] {
        var result: [Device] = []
        let devices = (sources == nil || sources!.count == 0) ? deviceList : sources!
        //可视化：展开时才添加支路，实际时：visible=false
        if (visiable ? !device.collapsed : true) {
            device.getBranches().forEach { branch in
                if let branchDevice = devices.first(where: { $0.id == branch }) {
                    result.append(branchDevice)
                    //若之路还有支路，继续循环
                    if !branchDevice.branch.isEmpty {
                        result.append(contentsOf: getBranceList(device: branchDevice, visiableOnly: visiable, sources: devices))
                    }
                }
            }
        }
        return result
    }

    func getParent(of child: Device) -> Device? {
        return deviceList.first { $0.branch.contains(child.getShortID()) }
    }

    static func setImage(in imageView: UIImageView, with device: Device) {
        if !device.image.isEmpty {
            imageView.kf.setImage(with: device.image.getEDSServletImageUrl())
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = device.getDefaultImage()
        }
    }


    /// 在创建工单页面，下拉框弹出设备树，为简化为文本格式设备树层级，采用文本缩进形式
    ///Level 1xxxxxxx
    ///    Level 2xxxxxxx
    ///        Level 3xxxxxxx
    func indentDeviceListText() -> [String] {
        let devices = getProjDeviceList(visiableOnly: false)
        return devices.map {
            switch $0.level {
            case .room:
                return $0.title
            case .box:
                return String((0..<6).map { _ in return " " }) + $0.title
            default:
                return String((0..<12).map { _ in return " " }) + $0.title
            }
        }
    }

    /// 将设备按状态归类：在线，离线，报警，其他（非通讯型）
    func classifyDevice(dynamicStates: [DynamicDeviceModel]?) -> Dictionary<DeviceClass, [Device]> {
        let states: [DynamicDeviceModel] = (dynamicStates == nil) ? getDynamicTags() : dynamicStates!
        var result: Dictionary<DeviceClass, [Device]> = [:]

        DeviceClass.allCases.forEach { type in
            switch type {
            case .online:
                let devices = states.filter { $0.getState() != .offline }.map { $0.device }
                result[type] = devices
            case .offline:
                let devices = states.filter { $0.getState() == .offline }.map { $0.device }
                result[type] = devices
            case .alarm:
                let devices = states.filter { $0.getState() == .alarm }.map { $0.device }
                result[type] = devices
            case .other:
                let devices = deviceList.filter { $0.level != .dynamic }
                result[type] = devices
            }
        }
        return result
    }

    /// 找到所有通讯设备状态点，及所属设备，设备类型
    func getDynamicTags() -> [DynamicDeviceModel] {
        var results: [DynamicDeviceModel] = []
        deviceList.forEach { device in
            guard device.level == .dynamic else {
                return
            }
            let deviceType = TagUtility.getDeviceType(with: device.getShortID())
            guard let deviceModel = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType }) else {
                return
            }
            let tags = TagUtility.sharedInstance.getTagList(by: [deviceModel.status.tag], in: device.getShortID())
            if let tag = tags.first {
                results.append(DynamicDeviceModel(device, deviceModel, tag))
            }
        }
        return results
    }
}
