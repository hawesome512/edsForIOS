//
//  Device.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  资产设备

import Foundation
import HandyJSON

class Device: HandyJSON {

    //工程🆔与时间戳点间隔符号
    private let idSeparator = "-"
    //详情数组分割符号
    private let listSeparator = ";"

    //🆔，e.g.:1/XRD-20181010164444 (ProjectID-创建时间）
    var id: String = ""
    //资产归属，当Account为空发送更新请求时，后台将删除设备
    var account: String = ""
    //资产编号命名
    var title: String = ""
    //资产属性
    var level: DeviceLevel = .room
    //包含支路
    var branch: String = ""
    //图片信息
    var image: String = ""
    //资料编辑
    var editor: String = ""
    //资料更新时间
    var time: String = ""

    //跟后台数据模型无关，为设备列表折叠服务，⚠️待验证是否会影响与服务器数据传输
    //折叠or展开，在配电房/配电箱显示or隐藏branch，默认折叠
    var collapsed = true

    required init() { }

    init(deviceID: String) {
        //创建工单必填项
        self.id = deviceID
    }

    //与父设备里branch相同
    func getShortID() -> String {
        return id.components(separatedBy: idSeparator)[1]
    }

    //MARK: -资产信息列表相关
    func getBranches() -> [String] {
        let projID = id.components(separatedBy: idSeparator)[0]
        return branch.components(separatedBy: listSeparator).map { projID + idSeparator + $0 }
    }

    func getTintColor() -> UIColor {
        return level == .room ? UIColor.black : UIColor.darkGray
    }

    func getIcon() -> UIImage? {
        //device_box
        return UIImage(named: "device_\(level)")?.withTintColor(getTintColor())
    }

    func getAccessoryView() -> UIView? {
        switch level {
        case .room, .box:
            //只要配电房/箱可以添加设备
            return UIImageView(image: UIImage(systemName: "plus"))
        default:
            return nil
        }
    }

    func getCollapsedImage() -> UIImage? {
        switch level {
        case .room, .box:
            //折叠or展开箭头方向不同
            return UIImage(systemName: collapsed ? "chevron.right" : "chevron.down")
        default:
            return nil
        }
    }

    func getCellType() -> DeviceCellType {
        switch level {
        case .dynamic:
            return .dynamic
        default:
            return .fixed
        }
    }

    //cell缩进等级
    func getIndentationLevel() -> Int {
        switch level {
        case .room:
            return 1
        case .box:
            return 2
        default:
            return 5
        }
    }
}

//资产设备类型：配电房，配电箱，静态设备（非通信型），动态设备（通信型）
enum DeviceLevel: Int, HandyJSONEnum {
    case room = 0
    case box = 1
    case fixed = 2
    case dynamic = 3
}

