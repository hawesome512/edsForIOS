//
//  Energy.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  用电分析类
//  尖峰平谷计算模式说明：
//  将一天分为48个时段：0.5h/时段
//  在查询用电数据时，为保证查询数据的响应速度，最小粒度只到小时，故将小时数据平分给不同时区
//  e.g.: 查询xx年xx月xx日7:00～8:00用电：1000kW.h，7:00～7:30属平段，7:30～8:00属峰段
//        则：平段=峰段=1000/2=500

import Foundation
import HandyJSON

class Energy: HandyJSON {
    
    static let timeSeparator = "/"
    private let branchSeparator = ";"
    private let branchInfoSeparator = "/"
    
    //工程id
    var id: String = ""
    //用电支路
    var branch: String = ""
    //valley time:低谷时间范围
    var vt: String = ""
    //valley price低谷电价
    var vp: String = ""
    //flat time:平段时间范围
    var ft: String = ""
    //flat price:平段电价
    var fp: String = ""
    //peak time:高峰时间范围
    var pt: String = ""
    //peak price:高峰电价
    var pp: String = ""
    //sharp time:尖峰时间范围
    var st: String = ""
    //sharp price:尖峰电价
    var sp: String = ""
    //已舍弃，币制符号：$ ￥
    var currency: String = ""
    
    required init() { }
    
    func getHourDic() -> Dictionary<Int,EnergyTime> {
        var hourDic: Dictionary<Int, EnergyTime> = [:]
        getHours(vt).forEach{ hourDic[$0] = .valley }
        getHours(ft).forEach{ hourDic[$0] = .flat }
        getHours(pt).forEach{ hourDic[$0] = .peak }
        getHours(st).forEach{ hourDic[$0] = .sharp }
        return hourDic
    }
    
    func getTimeData() -> [TimeData] {
        var datas = [TimeData]()
        datas.append(TimeData(energyTime: .valley, hours: getHours(vt), price: vp))
        datas.append(TimeData(energyTime: .flat, hours: getHours(ft), price: fp))
        datas.append(TimeData(energyTime: .peak, hours: getHours(pt), price: pp))
        datas.append(TimeData(energyTime: .sharp, hours: getHours(st), price: sp))
        return datas
    }
    
    func setTimeData(_ datas: [TimeData]) {
        datas.forEach{ data in
            switch data.energyTime {
            case .valley:
                vt = data.hours.map{ "\($0)" }.joined(separator: Energy.timeSeparator)
                vp = "\(data.price)"
            case .flat:
                ft = data.hours.map{ "\($0)" }.joined(separator: Energy.timeSeparator)
                fp = "\(data.price)"
            case .peak:
                pt = data.hours.map{ "\($0)" }.joined(separator: Energy.timeSeparator)
                pp = "\(data.price)"
            case .sharp:
                st = data.hours.map{ "\($0)" }.joined(separator: Energy.timeSeparator)
                sp = "\(data.price)"
            }
        }
    }
    
    private func getHours(_ hour: String) -> [Int]{
        let temps = hour.components(separatedBy: Energy.timeSeparator).map{ Int($0) }.filter{ $0 != nil }
        return temps as! [Int]
    }
}

class TimeData {
    //全天分成48段（半小时）
    static let hourSectionCount = 48
    
    var energyTime: EnergyTime
    var hours: [Int] = []
    var price: Double = 0
    //区间电量
    var totalValue: Double = 0
    
    init(energyTime: EnergyTime, hours: [Int], price: String){
        self.energyTime = energyTime
        self.hours = hours
        self.price = Double(price) ?? 0
    }
    
    func getMoney() -> Double {
        return totalValue * price
    }
    
    func toHourRangeString() -> String {
        var range = getHourStart(hours[0])
        let count = hours.count
        for i in 1..<count {
            if hours[i] != hours[i-1] + 1 {
                range += "~\(getHourEnd(hours[i-1]))/\(getHourStart(hours[i]))"
            }
        }
        range += "~\(getHourEnd(hours[count-1]))"
        return range
    }
    
    private func getHourStart(_ index: Int) -> String {
        return index % 2 == 0 ? "\(index/2):00" : "\(index/2):30"
    }
    
    private func getHourEnd(_ index: Int) -> String {
        return index % 2 == 0 ? "\(index/2):30" : "\(index/2+1):00"
    }
}

enum EnergyTime: Int,CaseIterable {
    //低谷，电费50%
    case valley
    //平段
    case flat
    //高峰，电费150%
    case peak
    //尖峰，电费170%
    case sharp
    
    func getText() -> String {
        return String(describing: self).localize(with: prefixEnergy)
    }
    
    func getColor() -> UIColor {
        switch self {
        case .valley:
            return .systemGreen
        case .flat:
            return .systemBlue
        case .peak:
            return .systemYellow
        case .sharp:
            return .systemRed
        }
    }
}
