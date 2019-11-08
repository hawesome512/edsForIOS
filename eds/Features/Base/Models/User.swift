//
//  User.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/8.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  用户资料

import Foundation

class User {
    
    //用户密钥～[username:password]，base64加密
    var authority:String?
    //用户权限等级
    var userLevel:UserLevel
    //用户所属的工程设备，一个用户只能拥有一个工程
    var deviceName:String
    
    init(base64Authority:String, ownedDeviceName:String) {
        authority = base64Authority
        deviceName = ownedDeviceName
        userLevel = .usernameAdmin
    }
    
}

enum UserLevel {
    //超级管理员，EDS开发人员专有，可以修改EDS系统、发布工单等
    case superAdmin
    //工程管理员，每个工程客户一个，账户名+密码，用于Web+App登陆、管理，授权一般管理员和普通访客
    case usernameAdmin
    //一般管理员，由工程管理员授权相应的手机号，+验证码用于App登陆、管理
    case phoneAdmin
    //普通访客，由工程&一般管理员授权的手机号，可查看、无任何操作权限
    case phoneGuest
    //临时访客，由工程/一般管理员授权二维码，扫码登录，限时，一次性
    case qrcodeGuest
}
