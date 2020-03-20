//
//  User.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/8.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  用户资料

import Foundation
import HandyJSON

class User {

    //用户密钥～[username:password]，base64加密
    var authority: String?
    //用户权限等级
    var userLevel: UserLevel = .unLogin
    //用户所属的工程设备，一个用户只能拥有一个工程
    var projectID: String?
    //头像
    var image: UIImage?
    //用户名
    var name: String?

    //单例
    static let sharedInstance = User()
    //调试时的测试用户【临时】
    static let tempInstance: User = {
        let user = User()
        user.authority = "guest:xseec".toBase64()
        user.projectID = "2/XRD"
        user.userLevel = .phoneAdmin
        return user
    }()

    private init() { }

    func onLoginSuccess(base64Authority: String, ownedProjectID: String) {
        authority = base64Authority
        projectID = ownedProjectID
        userLevel = .usernameAdmin
    }

    //EDS Service工单、记录等数据模型需要ID
    func generateID() -> String {
//        return "\(projectID ?? NIL)-\(Date().toIDString())"
        return "\(projectID ?? NIL)-\(String.randomString(length: 3))"
    }

    func generateImageID() -> String {
        let project = projectID?.replacingOccurrences(of: "/", with: "_")
        return "\(project ?? NIL)_\(String.randomString(length: 3))"
    }

    //e.g.:XRD
    func getProjectName() -> String? {
        return projectID?.components(separatedBy: "/").last
    }

    func isOperable() -> Bool {
        return userLevel.rawValue <= UserLevel.phoneAdmin.rawValue
    }
}
