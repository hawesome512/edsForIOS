//
//  WATagLogRequestBody.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/6.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  WA请求监控点的DataLog需要RequestBody

import Foundation
import HandyJSON
import SwiftDate

struct LogTag: HandyJSON {

    static let nilValue = "#"

    // Name……等未采用Swift语法～小驼峰命名，是为了方便HandyJSON将Tag转化为符合WA的Json格式
    var Name: String = NIL
    // 数据类型：取时间段内的最后值、最小值、最大值、平均值
    var DataType: LogDataType = .Last
    // 值的数组
    var Values: [String]?

    init() { }

    init(name: String, logDataType: LogDataType) {
        Name = name
        DataType = logDataType
    }

    func getTagShortName() -> String {
        return Name.components(separatedBy: Tag.nameSeparator)[1]
    }

}

struct WATagLogRequestCondition: HandyJSON {

    //起始时间，格式为：yyyy-mm-dd HH:MM:SS
    var StartTime: String = "2019-01-01 00:00:00"
    //查询等时间单位， S<秒>, M<分>, H<时>, D<日>，使用String而非直接枚举类型是为乐方便Moya传参数
    var IntervalType: String = LogIntervalType.S.rawValue
    //每笔资料等时间间隔，以IntervalType为单位
    var Interval: Int = 1
    //欲查询的资料笔数
    var Records: Int = 1
    //欲查询的“监控点”数组，使用JSON格式，而非字符串
    var Tags: [[String: Any]?] = []

    init() { }

    init(startTime: String, intervalType: LogIntervalType, interval: Int, records: Int, tags: [LogTag]) {
        StartTime = startTime
        IntervalType = intervalType.rawValue
        Interval = interval
        Records = records
        Tags = tags.toJSON()
    }


    /// 默认查询条件：过去一天
    /// - Parameters:
    ///   - tags: <#tags description#>
    ///   - dataType: <#dataType description#>
    static func defaultCondition(with tags: [Tag], isAccumulated: Bool) -> WATagLogRequestCondition {
        //累加值取最后值，其他默认取平均值
        let dataType: LogDataType = isAccumulated ? .Last : .Avg
        let logTags = tags.map { LogTag(name: $0.Name, logDataType: dataType) }
        //从整点开始
        let startTime = Date().add(by: .day, value: -1).dateAtStartOf(.hour).toDateTimeString()
        //record+1个实现完整区间，如1.1 12:00一1.2 12:00
        return WATagLogRequestCondition(startTime: startTime, intervalType: .H, interval: 1, records: 24 + 1, tags: logTags)
    }


    /// 报警查询条件：前后5分钟，最大值
    /// - Parameters:
    ///   - tags: <#tags description#>
    ///   - time: <#time description#>
    static func alarmCondition(with tags: [Tag], time: String) -> WATagLogRequestCondition {
        let logTags = tags.map { LogTag(name: $0.Name, logDataType: .Max) }
        //应当设置local，否则定为0时区的时间
        let startTime = (time.toDate(nil, region: .local)! - 3.minutes).date.toDateTimeString()
        return WATagLogRequestCondition(startTime: startTime, intervalType: .S, interval: 5, records: 60, tags: logTags)
    }


    /// 获取间隔点的时间显示样式，用于DeviceTrendChartCell>横坐标
    /// - Parameter index: <#index description#>
    func getShortTimeString(with index: Int) -> String {
        guard var time = StartTime.toDate() else {
            return "\(index)"
        }
        switch LogIntervalType(rawValue: IntervalType) {
        case .D:
            //如果是月首1号，直接显示月份名：1月。。。
            time = time + (Interval * index).days
            return time.toFormat("MMM d")
        case .H:
            time = time + (Interval * index).hours
            let hour = time.hour
            return hour == 0 ? time.toFormat("MMM d") : time.toFormat("H:00")
        case .M:
            time = time + (Interval * index).minutes
            return time.toFormat("H:m")
        case .S:
            time = time + (Interval * index).seconds
            return time.toFormat("H:m:s")
        default:
            return "\(index)"
        }
    }

    /// 获取间隔点的具体时间显示样式，用于DeviceTrendAnalysisCell>最大/小值时间
    /// - Parameter index: <#index description#>
    func getLongTimeString(with index: Int) -> String {
        guard var time = StartTime.toDate() else {
            return "\(index)"
        }
        switch LogIntervalType(rawValue: IntervalType) {
        case .D:
            //如果是月首1号，直接显示月份名：1月。。。
            time = time + (Interval * index).days
            return time.toFormat("yyyy MMM d")
        case .H:
            time = time + (Interval * index).hours
            return time.toFormat("yyyy MMM d H:00")
        case .M:
            time = time + (Interval * index).minutes
            return time.toFormat("yyyy MMM d H:m:00")
        case .S:
            time = time + (Interval * index).seconds
            return time.toFormat("yyyy MMM d H:m:s")
        default:
            return "\(index)"
        }
    }
}

//枚举：需要增加（:String/Int……)才能使用rawValue
enum LogIntervalType: String, HandyJSONEnum {
    case S = "S"
    case M = "M"
    case H = "H"
    case D = "D"
}

//研华提供的API说明文档错误，Max与Min颠倒
enum LogDataType: String, HandyJSONEnum {
    case Last = "0"
    case Max = "1"
    case Min = "2"
    case Avg = "3"
}
