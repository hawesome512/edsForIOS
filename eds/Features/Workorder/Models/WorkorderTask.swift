//
//  WorkorderTask.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import HandyJSON

struct WorkorderTask {
    var title: String?
    var state: WorkorderTaskState = .unchecked

    init(title: String) {
        //在服务器数据库中任务信息存储格式:任务1_0;任务2_2;……，在任务title中不应包含这两个分隔符号
        var validTitle = title
        validTitle.removeCharacters(chars: "_;")
        self.title = validTitle
    }

    func toString() -> String {
        return "\(title ?? NIL)_\(state.rawValue)"
    }

    static func generate(with task: String) -> WorkorderTask? {
        //e.g.:清洁卫生_1
        let pattern = "(\\w+)_([01])"
        let range = NSRange(location: 0, length: task.count)
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        if let result = regex?.firstMatch(in: task, options: [], range: range) {
            let title = (task as NSString).substring(with: result.range(at: 1))
            var wTask = WorkorderTask(title: title)
            let value = (task as NSString).substring(with: result.range(at: 2))
            wTask.state = WorkorderTaskState(rawValue: value) ?? .unchecked
            return wTask
        } else {
            return nil
        }
    }
}

enum WorkorderTaskState: String {
    case unchecked = "0"
    case checked = "1"
}

struct WorkorderTaskModel: HandyJSON {

    //说明书列表
    var instructions: [String]?
    //任务类型
    var tasks: [WorkorderTaskType]?

    static let sharedInstance: WorkorderTaskModel? = {
        if let path = Bundle.main.path(forResource: "Workorder", ofType: "json") {
            if let json = try? JSON(data: Data(contentsOf: URL(fileURLWithPath: path))) {
                var model = WorkorderTaskModel.deserialize(from: json.description)
                model?.instructions?[0] = "instruction_none".localize(with: prefixWorkorder)
                model?.tasks?[0].task = "task_custom".localize(with: prefixWorkorder)
                return model
            }
        }
        return nil
    }()
}

struct WorkorderTaskType: HandyJSON {
    var task: String?
    var items: [String]?
}
