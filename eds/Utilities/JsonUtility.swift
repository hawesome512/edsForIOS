//
//  JsonUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/12.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  将网络请求返回的数据转换为指定的格式

import Foundation
import SwiftyJSON
import HandyJSON
import CocoaMQTT

class JsonUtility {

    //MARK: - WAService---------------------------
    class func getProjectID(data: Data) -> String? {
        //用户登录成功，获取projecID
        guard let json = try? JSON(data: data) else {
            return nil
        }
        return json["UserInfo", "Description"].stringValue
    }

    class func getTagList(data: Data) -> [Tag?]? {
        let jsonString = String(data: data, encoding: .utf8)
        return [Tag].deserialize(from: jsonString, designatedPath: "Tags")
    }

    class func getTagValues(data: Data) -> [Tag?]? {
        let jsonString = String(data: data, encoding: .utf8)
        return [Tag].deserialize(from: jsonString, designatedPath: "Values")
    }

    class func didSettedValues(data: Data) -> Bool {
        //判断修改成功与否
        guard let json = try? JSON(data: data) else {
            return false
        }
        return json["Ret"].int != nil
    }

    class func getTagLogValues(data: Data) -> [LogTag?]? {
        let jsonString = String(data: data, encoding: .utf8)
        return [LogTag].deserialize(from: jsonString, designatedPath: "DataLog")
    }


    //MARK: - EDSService---------------------------

    //EDS Service所有post操作响应格式都一样,所有get响应都应处理服务器回传的数据中\"null\"代表空数据的字符串[removeNull]
    class func didUpdatedEDSServiceSuccess(data: Data) -> Bool {
        if let json = try? JSON(data: data) {
            return json["resultCode"].intValue == 1
        }
        return false
    }

    //EDS Service所有get操作响应格式都一样，设计泛型方法，type只是为了传入数据类型
    //e.g.:getEDSServiceList(with:response.data,type:[Device]())
    class func getEDSServiceList<T:HandyJSON>(with data: Data, type: [T]) -> [T?]? {
        let jsonString = String(data: data, encoding: .utf8)?.removeNull()
        return [T].deserialize(from: jsonString)
    }

    //EDS Service手机验证登录，获取结果，验证成功将工程密钥base64置于返回数据的String中
    class func getPhoneVerifyResult(data: Data) -> (PhoneVerificationResult?, String?)? {
        if let json = try? JSON(data: data) {
            let code = json["resultCode"].intValue
            let message = json["message"].stringValue
            return (PhoneVerificationResult(rawValue: code), message)
        }
        return nil
    }

    //MARK: - MQTTService---------------------------
    class func getMQTTTagList(message: CocoaMQTTMessage) -> [MQTTTag?]? {
        return [MQTTTag].deserialize(from: message.string, designatedPath: "d")
    }
}
