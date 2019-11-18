//
//  MQTTTag.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  MQTT格式的数据模型，名称和类型不同于Tag

import Foundation
import HandyJSON

class MQTTTag: HandyJSON {

    var tag: String = "null"
    //不同于Tag,此处为Double格式，与Simple MQTT cmd格式相匹配
    var value: Double?

    required init() { }

    init(name: String) {
        tag = name
    }

    init(name: String, value: Double) {
        tag = name
        self.value = value
    }
}
