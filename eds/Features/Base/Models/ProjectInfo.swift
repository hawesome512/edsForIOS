//
//  ProjectInfo.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/12.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  用户工程节点基本信息

import Foundation
import HandyJSON

struct ProjectInfo: HandyJSON {

    //更详细解析规则见于《EDS Servlet API》文档
    //登录用户所有的工程节点ID，e.g.:1/XRD
    var id: String = ""
    //工程节点名称,e.g.:厦门士林电机有限公司
    var user: String = ""
    //头图，显示在APP首页，e.g.:xs.jpg
    var banner: String = ""
    //站点负责人，e.g.:徐海生 18759282157
    var pricipal: String = ""
    //站点位置，e.g.:厦门市 集美区 孙坂南路92号
    var location: String = ""
    //工程图库，e.g.:A.jpeg;B.jpeg;C.jpeg……
    var image: String = ""
    //资产编号，e.g.:CY-成宇厂;CY_A2_2-空压机;……
    var alias: String = ""
    //能耗节点，e.g.:0/*/厦门士林电机;00/XS_A3_1:Ep/制造;01/XS_A3_2:Ep/办公楼……
    var energy: String = ""

    init() { }

    init(projectID: String) {
        //必填项
        id = projectID
    }

}
