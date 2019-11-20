//
//  MQTTService.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  MQTT Service,MQTT将实现数据的快速更新

import Foundation
import CocoaMQTT
import HandyJSON

class MQTTService {

    //单例，只允许存在一个实例
    static let sharedInstance = MQTTService(config: MQTTConfig())

    private let mqtt: CocoaMQTT

    var delegate: MQTTServiceDelegate? {
        didSet {
            if let delegate = delegate {
                mqtt.didReceiveMessage = delegate.didReceiveMessage
            }
        }
    }

    private init(config: MQTTConfig) {
        let clientID = "EDSMQTT-" + UUID().uuidString
        mqtt = CocoaMQTT(clientID: clientID, host: config.host, port: config.port)
        mqtt.username = config.username
        mqtt.password = config.password
        //订阅or发布指令必须在connec之后
        let connected = mqtt.connect()
        print("MQTT Connected:\(connected).")
    }

    //ProjectID:1/XRD,ProjectName:XRD
    func refreshTagValues(projectName: String) {
        //订阅格式：data/XRD，数据格式参照研华网关SimpleMQTT
        mqtt.subscribe("data/" + projectName)

    }

    func updateTagValues(projectName: String, updatedTags: [MQTTTag]) {
        let jsonString = MQTTUpdateTagsBody(tags: updatedTags).toJSONString()!
        //发布格式：cmd/XRD，数据格式参照研华网关SimpleMQTT
        mqtt.publish("cmd/" + projectName, withString: jsonString)
    }

    deinit {
        if mqtt.connState == .connected {
            mqtt.disconnect()
            print("MQTT Disconnected.")
        }
    }

}

protocol MQTTServiceDelegate {
    func didReceiveMessage(mqtt: CocoaMQTT, message: CocoaMQTTMessage, flag: UInt16)
}

//MQTT修改参数需要的JSON格式（Simple MQTT)
class MQTTUpdateTagsBody: HandyJSON {

    //计划提交改变的Tag
    var updatedTags: [MQTTTag]?
    //时间戳,与网关默认设置选择UTC
    var timestamp: String?

    required init() { }

    init(tags: [MQTTTag]) {
        updatedTags = tags
        timestamp = Date().toUTCString()
    }

    //选择符合Simple MQTT的Json格式
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.updatedTags <-- "w"
        mapper <<< self.timestamp <-- "ts"
    }

}
