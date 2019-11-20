//
//  Project.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/5.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  EDS服务器节点信息，云平台模式+本地部署，开放接口允许用户修改

import Foundation

class EDSConfig {

    static let servicePath: String = UserDefaults.standard.string(forKey: "servicePath") ?? "https://www.eds.ink"
    static let projectName: String = UserDefaults.standard.string(forKey: "projeceName") ?? "EDS"
    static let nodeName: String = UserDefaults.standard.string(forKey: "nodeName") ?? "XS"

    class func saveConfig(servicePath: String, projectName: String, nodeName: String) {
        UserDefaults.standard.set(servicePath, forKey: "servicePath")
        UserDefaults.standard.set(projectName, forKey: "projectName")
        UserDefaults.standard.set(nodeName, forKey: "nodeName")
    }
}
