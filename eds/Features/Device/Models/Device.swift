//
//  Device.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  资产设备

import Foundation
import HandyJSON

class Device: HandyJSON, Equatable, EDSDelegate {

    static let icon = UIImage(systemName: "bolt.circle")
    static let description = "property".localize()

    //工程🆔与时间戳点间隔符号
    private let idSeparator = "-"
    //详情数组分割符号
    private let listSeparator = ";"

    //处理情况：branch惟有一个设备，在删除支路时，branch将为空值，上传到服务器时，branch未能正常从数据库中删除
    //所以，当需要更新branch且其无支路时，置nilBranch
    private let nilBranch = "\"null\""

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
    //资料编辑,e.g.:Name1(unit):Value1;Name2(unit):Value2……
    var infos: String = ""

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

    func getInfos() -> [DeviceInfo] {
        return infos.components(separatedBy: listSeparator).map { DeviceInfo.initInfo(with: $0) }.filter { $0 != nil } as! [DeviceInfo]
    }

    func setInfos(infos: [DeviceInfo]) {
        self.infos = infos.map { $0.toString() }.joined(separator: listSeparator)
    }

    func prepareForDelete() {
        //不能设置为nil,因为设置为nil时handyjson不会将account为空值的信息转化上传
        account = ""
    }

    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }

    //MARK: -资产信息列表相关
    func getBranches() -> [String] {
        let projID = id.components(separatedBy: idSeparator)[0]
        return branch.components(separatedBy: listSeparator).map { projID + idSeparator + $0 }
    }

    func addBranch(with shortId: String) {
        branch = branch.removeNull().isEmpty ? shortId : (branch + listSeparator + shortId)
    }

    func removeBranch(with shortId: String) {
        branch = branch.removeNull()
        //正则表达式处理，移除多余的分隔符：；
        let pattern = "\(shortId);*"
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        let range = NSRange(location: 0, length: branch.count)
        if let newBranch = regex?.stringByReplacingMatches(in: branch, options: [], range: range, withTemplate: "") {
            branch = newBranch.trimmingCharacters(in: CharacterSet(charactersIn: listSeparator))
        }
        if branch.isEmpty {
            branch = nilBranch
        }
    }

    func getTintColor() -> UIColor {
        return level == .room ? UIColor.black : UIColor.darkGray
    }

    func getIcon() -> UIImage? {
        //device_box
        return UIImage(named: "device_\(level)")?.withTintColor(getTintColor())
    }

    func getDefaultImage() -> UIImage? {
        if level == .dynamic {
            let infos = getShortID().components(separatedBy: Tag.deviceSeparator)
            return infos.count == 3 ? UIImage(named: "device_" + infos[1]) : nil
        } else {
            return getIcon()
        }
    }

    func getAccessoryView() -> UIButton? {
        switch level {
        case .room, .box:
            //只要配电房/箱可以添加设备
            return UIButton(type: .contactAdd)
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

struct DeviceInfo {

    static let infoSeparator = ":"
    var title: String = ""
    var value: String = ""

    static func initInfo(with info: String) -> DeviceInfo? {
        let infos = info.components(separatedBy: DeviceInfo.infoSeparator)
        if infos.count == 2 {
            var deviceInfo = DeviceInfo()
            deviceInfo.title = infos[0]
            deviceInfo.value = infos[1]
            return deviceInfo
        } else {
            return nil
        }
    }

    func toString() -> String {
        return title + DeviceInfo.infoSeparator + value
    }
}

