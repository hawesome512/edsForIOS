//
//  EDSResourceUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/5.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  EDS服务后台资源列表

import Foundation
import RxCocoa

class EDSResourceUtility {

    static let sharedInstance = EDSResourceUtility()

    private(set) var helpList = [Help]()
    private(set) var successfulLoadedHelpList = BehaviorRelay<Bool>(value: false)

    private init() { }

    func loadHelpList() {
        guard helpList.count == 0 else {
            return
        }
        DispatchQueue.global().async {
            let path = EDSConfig.servicePath + ":8443/EDSServlet/upload/help/helplist.txt"
            if let list = try? String(contentsOf: URL(string: path)!) {
                self.helpList = list.components(separatedBy: "\r\n").filter { !$0.isEmpty }.map { Help($0) }
                self.successfulLoadedHelpList.accept(true)
                print("loaded project help list")
            }
        }
    }
    
    func clearResource(){
        helpList.removeAll()
        successfulLoadedHelpList.accept(false)
    }

}
