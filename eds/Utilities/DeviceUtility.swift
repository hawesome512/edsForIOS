//
//  DeviceUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya

class DeviceUtility {

    //通过单列调取资产设备列表设备
    var deviceList: [Device] = []
    //单例，只允许存在一个实例
    static let sharedInstance = DeviceUtility()

    private init() { }

    /// 从后台导入资产设备列表
    func loadProjectDeviceList() {
        //获取后台服务设备列表请求在生命周期中只有一次
        guard deviceList.count == 0 else {
            return
        }
        let factor = EDSServiceQueryFactor(id: TagUtility.sharedInstance.tempProjectID)
        MoyaProvider<EDSService>().request(.queryDeviceList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[tag?]?👉[tag]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Device]())
                self.deviceList = (tempList?.filter { $0 != nil })! as! [Device]
                print("TagUtility:Load project device list.")
            default:
                break
            }
        }
    }

    func getVisibleDeviceList() -> [Device] {
        var result: [Device] = []
        deviceList.filter { $0.level == .room }.forEach {
            result.append($0)
            result.append(contentsOf: getBranceList(device: $0))
        }
        return result
    }

    private func getBranceList(device: Device) -> [Device] {
        var result: [Device] = []
        //展开时才添加支路
        if !device.collapsed {
            device.getBranches().forEach { branch in
                if let branchDevice = deviceList.first(where: { $0.id == branch }) {
                    result.append(branchDevice)
                    //若之路还有支路，继续循环
                    if !branchDevice.branch.isEmpty {
                        result.append(contentsOf: getBranceList(device: branchDevice))
                    }
                }
            }
        }
        return result
    }
}
