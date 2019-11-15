//
//  ProjectAccount.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/14.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  工程账户管理

import Foundation
import HandyJSON

class ProjectAccount: HandyJSON {

    //🆔，ProjectID
    var id = ""
    //WAService数据请求密钥，base64加密
    var authority = ""
    //授权给工程用户手机号管理容量
    var number = 1
    //已授权的手机号，用分号【；】分割
    var phone = ""

    required init() { }

    init(projectID: String) {
        //必填
        id = projectID
    }
}
