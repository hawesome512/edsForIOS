//
//  DynamicDeviceModel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/13.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation

struct DynamicDeviceModel {
    var device: Device
    var type: DeviceType
    var tag: Tag

    init(_ device: Device, _ type: DeviceType, _ tag: Tag) {
        self.device = device
        self.type = type
        self.tag = tag
    }

    func getState() -> DeviceStatusType? {
        return TagValueConverter.getText(value: tag.getValue(), items: type.status.items).status
    }
}
