//
//  PhoneVerification.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/14.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  手机验证码

import Foundation
import HandyJSON

class PhoneVerification: HandyJSON {

    //🆔，手机号码
    var id = ""
    //验证码，4位数字
    var code = ""
    //验证码有效时间，系统后台生成5min内
    var time = ""
    //手机号用户等级
    var level = UserLevel.phoneAdmin
    //手机户主
    var name = ""
    //手机管理归属的ProjectID,e.g.:1/XRD
    var account = ""

    required init() { }

    init(phoneNumber: String) {
        id = phoneNumber
    }

}

//手机验证码登录流程：
//->◆号码已注册------no------------------------------------------------------------------->end:号码未注册
//             |---yes--->◆验证码为空------yes-------------------------------------------->end:生成验证码并发送至手机
//                                   ｜-- no---->◆验证码正确-------no--------------------->end:验证码错误
//                                                           |--yes---◆验证码超时---yes--->end:验证码超时
//                                                                              ｜-no--->end:验证成功，发送密钥至手机
enum PhoneVerificationResult: Int {
    //号码未注册
    case invalidPhone = 2
    //验证码错误
    case incorrectCode = 3
    //验证码超时
    case overtimeCode = 4
    //验证有效，获取Proje的登录密钥
    case validCode = 5
    //验证码已发送至手机
    case sendedCode = 6
}
