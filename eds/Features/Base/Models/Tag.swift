//
//  Tag.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/5.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  【监控点】

import Foundation
import HandyJSON

class Tag:HandyJSON{
    
    //Name和Value未采用Swift语法～小驼峰命名，是为了方便HandyJSON将Tag转化为符合WA的Json格式
    var Name:String = "null"
    var Value:String?
    
    required init() {}
    
    init(name:String) {
        Name = name
    }
    
    init(name:String,value:String) {
        Name = name
        Value = value
    }
}
