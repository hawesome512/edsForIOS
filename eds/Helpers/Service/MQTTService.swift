//
//  MQTTService.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  MQTT Service,MQTT将实现数据的快速更新
//  【注意】⚠️：不能初始化后，马上调用refresh or update，必须有时间间隔差
//  外部调用错误范例:1⃣️MQTTService.sharedInstance.delegate=self 首次调用shareInstance执行单例初始化init(建立mqtt.connect)
//                2⃣️MQTTService.sharedInstance.refreshTagValues("XRD") 刚connect马上订阅，将无效
//  未防止长时间处于后台，MQTT客户端无反应将被服务器舍弃，每次进入后台时都关闭链接，返回前台后新建mqtt客户端，退出EDS返回登录页面时也将关闭链接

import Foundation
import CocoaMQTT
import HandyJSON
import RxSwift

class MQTTService {

    private let disposeBag = DisposeBag()
    //单例，只允许存在一个实例
    static let sharedInstance = MQTTService()

    private var mqtt: CocoaMQTT = CocoaMQTT(clientID: "EDS")

    var delegate: MQTTServiceDelegate? {
        didSet {
            if let delegate = delegate {
                mqtt.didReceiveMessage = delegate.didReceiveMessage
            }
        }
    }

    private init() { }

    /// 订阅
    /// - Parameter projectName: ProjectID:1/XRD,ProjectName:XRD
    /// 若APP在后台一段时间(keepAlive=60s)，唤醒后尽管connect还是无法接收订阅内容，处理方法是唤醒后SceneDelegate>BecomeActive重新初始化MQTT建立新的客户端
    /// connect后不能马上订阅，设置3s延迟
    func subscribeTagValues(projectName: String) {
        let config = MQTTConfig()
        let clientID = "EDSMQTT-" + UUID().uuidString
        mqtt = CocoaMQTT(clientID: clientID, host: config.host, port: config.port)
        mqtt.username = config.username
        mqtt.password = config.password
        //订阅or发布指令必须在connec之后
        let connected = mqtt.connect()
        print("MQTT Connected:\(connected)")
        Observable<Int>.timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance).bind(onNext: { _ in
            self.mqtt.subscribe("data/" + projectName)
        }).disposed(by: disposeBag)

        //订阅格式：data/XRD，数据格式参照研华网关SimpleMQTT
//        mqtt.subscribe("data/" + projectName)
    }

    func unsubscribeTagValues(projectName: String) {
        mqtt.unsubscribe("data/" + projectName)
        if mqtt.connState == .connected {
            mqtt.disconnect()
            print("MQTT Disconnected.")
        }
    }

    func updateTagValues(projectName: String, updatedTags: [MQTTTag]) {
        let jsonString = MQTTUpdateTagsBody(tags: updatedTags).toJSONString()!
        //发布格式：cmd/XRD，数据格式参照研华网关SimpleMQTT
        mqtt.publish("cmd/" + projectName, withString: jsonString)
    }

    func description() -> String {
        return "MQTT Service Singleton has been init."
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
