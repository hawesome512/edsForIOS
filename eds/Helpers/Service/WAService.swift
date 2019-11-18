//
//  EDSService.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/5.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  WebAccess提供的API访问接口实现

import Moya
import Foundation

enum WAService {
    case login(authority: String) //登陆
    case getTagList(authority: String, projectID: String) //获取工程“监控点”集合
    case getTagValues(authority: String, tagList: [Tag]) //获取“监控点”的值
    case setTagValues(authority: String, tagList: [Tag]) //修改“监控点”点值
    case getTagLog(authority: String, requestBody: WATagLogRequestBody) //获取“监控点”历史记录

}

extension WAService: TargetType {

    var baseURL: URL {
        return URL(string: "\(EDSConfig.servicePath)/WaWebService/Json")!
    }

    var path: String {
        switch self {
        case .login:
            //eg:https://www.eds.ink/WaWebService/Json/getuserinfo/eds
            return "/GetUserInfo/\(EDSConfig.projectName)"
        case .getTagList(_, let projectID):
            //eg:https://www.eds.ink/WaWebService/Json/taglist/eds/xs/1/xrd
            return "/TagList/\(EDSConfig.projectName)/\(EDSConfig.nodeName)/\(projectID)"
        case .getTagValues:
            //eg:https://www.eds.ink/WaWebService/Json/gettagvalue/eds
            return "/GetTagValue/\(EDSConfig.projectName)"
        case .setTagValues:
            //eg:https://www.eds.ink/WaWebService/Json/settagvalue/eds
            return "/SetTagValue/\(EDSConfig.projectName)"
        case .getTagLog:
            //eg:https://www.eds.ink/WaWebService/Json/getdatalog/eds
            return "/GetDataLog/\(EDSConfig.projectName)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .getTagList:
            return .get
        case .getTagValues, .setTagValues, .getTagLog:
            return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .login, .getTagList:
            return .requestPlain
        case .getTagValues(_, let tagList), .setTagValues(_, let tagList):
            //在Reque body中以json格式传参数，tagList.toJSON()；此处尤为需要注意不能使用toJSONString(),因为它会在最外层加字符串双引号
            return .requestParameters(parameters: ["Tags": tagList.toJSON()], encoding: JSONEncoding.default)
        case .getTagLog(_, let requestBody):
            return .requestParameters(parameters: requestBody.toJSON()!, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .login(let authority), .getTagList(let authority, _), .getTagValues(let authority, _), .setTagValues(let authority, _), .getTagLog(let authority, _):
            return ["Content-type": "application/json;charset=utf-8", "Authorization": "Basic \(authority)"]
        }
    }

}
