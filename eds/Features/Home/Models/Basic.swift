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

    //以下属性已舍弃
    var pricipal: String = ""
    var image: String = ""
    var alias: String = ""

    required init() { }
}
