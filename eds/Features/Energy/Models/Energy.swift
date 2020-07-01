//
//  Energy.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

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
    //币制符号：$ ￥
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
