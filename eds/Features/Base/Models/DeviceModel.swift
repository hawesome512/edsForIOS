//
//  DeviceModel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/6.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  弱化设备（断路器)概念，直接从tag映射到显示页面，从配置文件device.json中匹配映射规则
//  目的是：随着设备的不断导入，不需要一次次修改app程序，动态从后台下载最新映射规则更新device.json

import Foundation
import SwiftyJSON
import HandyJSON

struct DeviceModel: HandyJSON {

    static let sharedInstance: DeviceModel? = {
        if let path = Bundle.main.path(forResource: "device", ofType: "json") {
            if let json = try? JSON(data: Data(contentsOf: URL(fileURLWithPath: path))) {
                return DeviceModel.deserialize(from: json.description)
            }
        }
        return nil
    }()

    //配置文件版本号，跟后台文件比对判断是否需要跟新
    var version = 1
    //设备类型列表，若设备不在列表中，值显示静态设备
    var types: [DeviceType] = []

}

struct DeviceType: HandyJSON {

    //设备类型，e.g.:A1，M2，T3……
    var type = ""
    //厂商，e.g.：xs
    var producer = ""
    //设备分类：断路器、电表……
    var category = ""
    //状态位，判断设备异常的tag
    var status = ""
    //异常报警图表中显示的tag列表，Ia/Ib/Ic
    var alarm: [String] = []
    //远程控制的验证权限,CtrlCode
    var authority: [String] = [String]()
    //设备页面列表,纵览/实时/遥控
    var pages: [DevicePage] = [DevicePage]()
}

struct DevicePage: HandyJSON {

    //设备页tab标题
    var title = ""
    //子项
    var content: [DevicePageItem] = [DevicePageItem]()
}

struct DevicePageItem: HandyJSON {

    //子项名称
    var name = ""
    //关联点列表
    var tags: [String] = [String]()
    //显示方式
    var display: DeviceDisplay?
    //附带参数
    var items: [String]?
    //换算单位
    var unit: String?
}

enum DeviceDisplay: String, HandyJSONEnum {
    //柱状图，对应的items为坐标范围
    case bar
    //可调参数，对应的items为步进
    case item
    //普通列表显示
    case list
    //水平指示，对应items为坐标范围
    case range
    //开关，对应items为开关index位
    case onoff
    //大标题文本显示
    case text
    //按钮*n
    case button
}
