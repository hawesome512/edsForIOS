//
//  Basic.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  工程基本信息

import Foundation
import HandyJSON

class Basic: HandyJSON {

    //🆔，e.g.:1/XRD-20181010164444 (ProjectID-创建时间）
    var id: String = ""
    //工程用户名,title
    var user: String = ""
    //工程头图
    var banner: String = ""
    //工程地址
    var location: String = ""
    //用电支路
    var energy: String = ""
    //公告
    var notice: String = ""
    //工程负责人，通常即为管理员，后台短信报警中心调用此信息以发送短信
    var pricipal: String = ""
    //以下属性已舍弃
    var image: String = ""
    var alias: String = ""

    required init() { }
    
    func setPricipal(with phone:Phone){
        let info = "\(phone.name!) \(phone.number!)"
        pricipal = info
    }
}
