//
//  WorkorderInfo.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  工单类型/创建人/审核人/工单编号

import Foundation

struct WorkorderInfo {
    var title: String
    var value: String

    //不从外部生成
    private init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    static func generateInfos(with workorder: Workorder) -> [WorkorderInfo] {
        var infos = [WorkorderInfo]()
        infos.append(WorkorderInfo(title: "created".localize(with: prefixWorkorder), value: workorder.creator))
        infos.append(WorkorderInfo(title: "executed".localize(with: prefixWorkorder), value: workorder.worker))
        infos.append(WorkorderInfo(title: "audited".localize(with: prefixWorkorder), value: workorder.auditor))
        infos.append(WorkorderInfo(title: "type".localize(with: prefixWorkorder), value: workorder.type.getText()))
        infos.append(WorkorderInfo(title: "serial_number".localize(with: prefixWorkorder), value: workorder.id))

        return infos
    }
}
