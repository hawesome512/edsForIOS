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
    
    //当设备数量不多时，默认全展开
    private let foldLimit = 10
    
    //单例，只允许存在一个实例
    static let sharedInstance = DeviceUtility()
    
    //通过单列调取资产设备列表设备
    private var deviceList: [Device] = []
    private(set) var successfulUpdated = BehaviorRelay<Bool>(value: false)
    
    private init() { }
    
    /// 从后台导入资产设备列表
    func loadProjectDeviceList() {
        guard let projID = AccountUtility.sharedInstance.account?.id else {
            return
        }
        let factor = EDSServiceQueryFactor(id: projID)
        EDSService.getProvider().request(.queryDeviceList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[tag?]?👉[tag]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Device]())
                self.deviceList = (tempList?.filter { $0 != nil })! as! [Device]
                if self.deviceList.count <= self.foldLimit {
                    self.deviceList.forEach { $0.collapsed = false }
                }
                self.successfulUpdated.accept(true)
                print("TagUtility:Load project device list.")
            default:
                break
            }
        }
    }
    
    // MARK: - DeviceList对外接口
    
    func add(_ device:Device, parent: Device?){
        parent?.addBranch(with: device.getShortID())
        //将上级设备设置展开属性，新增设备能直接显示在资产树中
        parent?.collapsed = false
        EDSService.getProvider().request(.updateDevice(device: device)) { response in
            switch response {
            case .success(_):
                //成功新增后，更新新增Device的父级支路
                guard let parent = parent else { return }
                EDSService.getProvider().request(.updateDevice(device: parent)) { _ in }
            default:
                break
            }
        }
        ActionUtility.sharedInstance.addAction(.addDevice, extra: device.title)
        deviceList.append(device)
        successfulUpdated.accept(true)
    }
    
    func remove(_ device: Device) {
        //设备及其支路设备
        var modifiedDevices = [device]
        modifiedDevices.append(contentsOf: getBranceList(device: device, visiableOnly: false))
        modifiedDevices = modifiedDevices.map { device in
            device.prepareForDelete()
            return device
        }
        deviceList = deviceList.filter { device in !modifiedDevices.contains(device) }
        
        //需要修改父级支路信息
        if let parent = getParent(of: device) {
            parent.removeBranch(with: device.getShortID())
            modifiedDevices.append(parent)
        }
        modifiedDevices.forEach({ device in
            EDSService.getProvider().request(.updateDevice(device: device)) { _ in }
        })
        
        print("modify \(modifiedDevices.count) devices.")
        ActionUtility.sharedInstance.addAction(.deleteDevice, extra: device.title)
        
        successfulUpdated.accept(true)
    }
    
    func update(_ device: Device) {
        EDSService.getProvider().request(.updateDevice(device: device)) { _ in }
        ActionUtility.sharedInstance.addAction(.editDevice, extra: device.title)
        //编辑设备不触发successfulUpdated.
    }
    
    func clearDeviceList(){
        deviceList.removeAll()
        successfulUpdated.accept(false)
    }
    
    func getDeviceList()->[Device]{
        return deviceList
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
        if devices.count==0,!successfulUpdated.value {
            //登录请求时加载数据失败，重新加载数据(排除工程中本来没有设备的情况）
            loadProjectDeviceList()
        }else{
            devices.filter { $0.level == .room }.forEach {
                result.append($0)
                result.append(contentsOf: getBranceList(device: $0, visiableOnly: visiableOnly, sources: devices))
            }
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
