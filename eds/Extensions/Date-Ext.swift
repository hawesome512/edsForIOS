//
//  Date-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/6.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation

extension Date {

    //格式：2019-01-01 10:10:10
    func toDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }

    //格式：2019-01-01 00:00:00
    func toDateStartTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
        return dateFormatter.string(from: self)
    }

    //格式：20190101000000，适用作为ID的时间戳
    func toIDString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: self)
    }

    //格式：2019-01-01
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    //格式：3月1 or Mar1
    func toShortDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMdd"
        return dateFormatter.string(from: self)
    }

    //格式：2019-10-01T12:00:00+0000
    func toUTCString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.string(from: self)
    }

    //格式：3月13 or Mar3
    func toShortDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMd"
        return dateFormatter.string(from: self)
    }

    //Date快速操作时间偏移
    func add(by component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }


}
