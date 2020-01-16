//
//  Tag.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/5.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  【监控点】

import Foundation
import HandyJSON
import RxCocoa

class Tag: HandyJSON {

    //分隔符，工程编码_设备类型_编号:Ia
    static let deviceSeparator = "_"
    static let nameSeparator = ":"
    //通信失败时用-1表示,多精读避免碰到刚好为-1的值
    static let nilValue: Double = -1.000123

    //Name和Value未采用Swift语法～小驼峰命名，是为了方便HandyJSON将Tag转化为符合WA的Json格式
    var Name: String = NIL
    var Value: String? {
        didSet {
            //发布Value更新，通知相应的ui观察者
            showValue.accept(getValue())
        }
    }

    //用于Rx绑定之UI中，因为value<String>可能为整数和浮点数，为防止外部调用Int(“浮点数字符串”出错）
    //Int("10.0")非法，Int(Double("10"))ok
    var showValue = BehaviorRelay<Double>(value: Tag.nilValue)

    required init() { }

    init(name: String) {
        Name = name
    }

    init(name: String, value: String) {
        Name = name
        Value = value
    }

    func getValue() -> Double {
        if let value = Value, let doubleValue = Double(value) {
            return doubleValue
        }
        return Tag.nilValue
    }


    /// 点所属的设备名：KB_A3_1:Ia，设备名为KB_A3_1
    func getDeviceName() -> String {
        return Name.components(separatedBy: Tag.nameSeparator)[0]
    }

    func getTagShortName() -> String {
        return Name.components(separatedBy: Tag.nameSeparator)[1]
    }
}
