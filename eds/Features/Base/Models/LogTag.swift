//
//  WATagLogRequestBody.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/6.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  WA请求监控点的DataLog需要RequestBody

import Foundation
import HandyJSON

struct LogTag: HandyJSON {

    // Name……等未采用Swift语法～小驼峰命名，是为了方便HandyJSON将Tag转化为符合WA的Json格式
    var Name: String = "null"
    // 数据类型：取时间段内的最后值、最小值、最大值、平均值
    var DataType: LogDataType = .Last
    // 值的数组
    var Values: [String] = []

    init() { }

    init(name: String, logDataType: LogDataType) {
        Name = name
        DataType = logDataType
    }

}

struct WATagLogRequestBody: HandyJSON {

    //起始时间，格式为：yyyy-mm-dd HH:MM:SS
    var startTime: String = "2019-01-01 00:00:00"
    //查询等时间单位， S<秒>, M<分>, H<时>, D<日>，使用String而非直接枚举类型是为乐方便Moya传参数
    var intervalType: String = LogIntervalType.S.rawValue
    //每笔资料等时间间隔，以IntervalType为单位
    var interval: Int = 1
    //欲查询的资料笔数
    var records: Int = 1
    //欲查询的“监控点”数组，使用JSON格式，而非字符串
    var tags: [[String: Any]?] = []

    init() { }

    init(startTime: Date, intervalType: LogIntervalType, interval: Int, records: Int, tags: [LogTag]) {
        self.startTime = startTime.toDateTimeString()
        self.intervalType = intervalType.rawValue
        self.interval = interval
        self.records = records
        self.tags = tags.toJSON()
    }
}

//枚举：需要增加（:String/Int……)才能使用rawValue
enum LogIntervalType: String, HandyJSONEnum {
    case S = "S"
    case M = "M"
    case H = "H"
    case D = "D"
}

enum LogDataType: String, HandyJSONEnum {
    case Last = "0"
    case Min = "1"
    case Max = "2"
    case Avg = "3"
}
