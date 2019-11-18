//
//  EDSService.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/12.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  EDS Service实现：工程用户信息，运维工单，异常，操作记录，上传图片，账户管理
//      ——所有的post格式响应的格式都相同
//      ——标志属性设计(ProjectInfo.user/Workorder.title/Alarm.alarm/Action.action/ProjectAccount.authority)
//        1⃣️id不存在且标志属性不为空，新增记录
//        2⃣️id存在且标志属性为空，删除记录
//        3⃣️id存在且标志属性不为空，修改记录
//      ——查询get操作中以start/end为筛选条件，时间格式：2019-01-01%2012:00:00，空格用“%20”代替


import Moya
import HandyJSON

enum EDSService {
    //获取工程站点列表
    case queryProjectInfoList(factor: EDSServiceQueryFactor)
    //更新工程站点基本信息
    case updateProject(projectInfo: HandyJSON)
    //获取运维工单列表
    case queryWorkorderList(factor: EDSServiceQueryFactor)
    //更新工单信息
    case updateWorkorder(workorder: HandyJSON)
    //获取异常列表
    case queryAlarmList(factor: EDSServiceQueryFactor)
    //更新异常信息
    case updateAlarm(alarm: HandyJSON)
    //获取操作记录列表
    case queryActionList(factor: EDSServiceQueryFactor)
    //更新操作记录信息
    case updateAction(action: HandyJSON)
    //获取工程账号列表
    case queryAccountList(factor: EDSServiceQueryFactor)
    //更新账号信息
    case updateAccount(account: HandyJSON)
    //手机验证码
    case verifyPhoneLogin(phoneVerification: HandyJSON)
    //上传图片
    case upload(fileURL: URL, fileName: String)
}

extension EDSService: TargetType {

    var baseURL: URL {
        return URL(string: "\(EDSConfig.servicePath):8443/EDSServlet")!
    }

    var path: String {
        switch self {
        case .queryProjectInfoList:
            return "/QueryBasicServlet"
        case .updateProject:
            return "/UpdateBasicServlet"
        case .queryWorkorderList:
            return "/QueryWorkorderServlet"
        case .updateWorkorder:
            return "/UpdateWorkorderServlet"
        case .queryAlarmList:
            return "/QueryAlarmServlet"
        case .updateAlarm:
            return "/UpdateAlarmServlet"
        case .queryActionList:
            return "/QueryActionServlet"
        case .updateAction:
            return "/UpdateActionServlet"
        case .queryAccountList:
            return "/QueryAccountServlet"
        case .updateAccount:
            return "/UpdateAccountServlet"
        case .verifyPhoneLogin:
            return "/QueryPhoneServlet"
        case .upload:
            return "/UploadServlet"
        }
    }

    var method: Moya.Method {
        switch self {
        case .queryProjectInfoList, .queryWorkorderList, .queryAlarmList, .queryActionList, .queryAccountList:
            return .get
        case .updateProject, .updateWorkorder, .updateAlarm, .updateAction, .updateAccount, .verifyPhoneLogin, .upload:
            return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .queryProjectInfoList(let factor), .queryWorkorderList(let factor), .queryAlarmList(let factor), .queryActionList(let factor), .queryAccountList(let factor):
            //get请求，参数置于url中
            return .requestParameters(parameters: factor.toJSON()!, encoding: URLEncoding.queryString)
        case .updateProject(let edsModel), .updateWorkorder(let edsModel), .updateAlarm(let edsModel), .updateAction(let edsModel), .updateAccount(let edsModel), .verifyPhoneLogin(let edsModel):
            //post请求，参数在Request Body中
            return .requestParameters(parameters: edsModel.toJSON()!, encoding: JSONEncoding.default)
        case .upload(let fileURL, let fileName):
            let imageData=MultipartFormData(provider: .file(fileURL), name: fileName, fileName: fileName, mimeType: "image/*")
            return .uploadMultipart([imageData])
        }
    }

    var headers: [String: String]? {
        switch self {
        case .upload:
            return ["Content-type": "application/octet-stream"]
        default:
            return ["Content-type": "application/json;charset=utf-8"]
        }
    }

}

//EDS Service查询的筛选条件
struct EDSServiceQueryFactor: HandyJSON {

    //id必填，start和end作为时间范围条件选填
    var id: String = ""
    var start: String?
    var end: String?

    init() { }

    init(id: String) {
        self.id = id
    }

    init(id: String, startTime: Date?, endTime: Date?) {
        self.id = id
        self.start = startTime?.toDateTimeString().toURLEncoding()
        self.end = endTime?.toDateTimeString().toURLEncoding()
    }
}