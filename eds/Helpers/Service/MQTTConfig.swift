//
//  MQTTConfig.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  MQTT Broker配置信息

import Foundation

struct MQTTConfig {

    //MQTT Broker IP，云服务器IP地址
    var host: String
    //MQTT Port，默认1883
    var port: UInt16
    //MQTT Broker用户名
    var username: String
    //MQTT Broker密码
    var password: String

    init() {
        host = UserDefaults.standard.string(forKey: "mqttHost") ?? "47.97.189.229"
        let defaultPort = UInt16( UserDefaults.standard.integer(forKey: "mqttPort"))
        port = defaultPort == 0 ? 1883 : defaultPort
        username = UserDefaults.standard.string(forKey: "mqttUsername") ?? "admin"
        password = UserDefaults.standard.string(forKey: "mqttPassword") ?? "admin"
    }

    func saveConfig(host: String, port: Int, username: String, password: String) {
        UserDefaults.standard.set(host, forKey: "mqttHost")
        UserDefaults.standard.set(port, forKey: "mqttPort")
        UserDefaults.standard.set(username, forKey: "mqttUsername")
        UserDefaults.standard.set(password, forKey: "mqttPassword")
    }
}
