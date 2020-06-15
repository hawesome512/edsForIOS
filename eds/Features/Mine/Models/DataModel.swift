//
//  DataModel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation

enum DataModel:CaseIterable {
    //数据有效期
    case dataValid
    //能耗有效期
    case energyValid
    //平台资源
    case systemLimit
    
    func getTitle() -> String {
        switch self {
        case .dataValid:
            return "dataValid".localize()
        case .energyValid:
            return ""
        case .systemLimit:
            return "systemLimit".localize()
        }
    }
    
    func getItems() -> [(title:String,value:String?)]{
        let items:[(title:String,value:String?)]
        switch self {
        case .dataValid:
            items = [
                ("accountInfo".localize(),"validLong".localize()),
                ("accountAction".localize(),"validMonth".localize()),
                (Alarm.description,"validYear".localize()),
                (Workorder.description,"validLong".localize())
            ]
        case .energyValid:
            let pattern = "\("title".localize(with: prefixEnergy))(%@)"
            items = [
                (String(format: pattern, "day".localize(with: prefixEnergy)),"validMonth".localize()),
                (String(format: pattern, "month".localize(with: prefixEnergy)),"validYear".localize()),
                (String(format: pattern, "year".localize(with: prefixEnergy)),"valid3Year".localize())
            ]
        case .systemLimit:
            items = [
                ("accountMember".localize(),nil),
                (Device.description,nil),
                ("propertyLevel".localize(),"3"),
                ("propertyInfo".localize(),"\(DeviceInfo.infoLimit)"),
                ("workorderImage".localize(),"\(Workorder.imageLimit)"),
                ("energyLevel".localize(),"\(EnergyBranch.levelLimit)"),
                ("energyLevelLimit".localize(),"\(EnergyBranch.branchLimit)")
            ]
        }
        return items
    }
}

