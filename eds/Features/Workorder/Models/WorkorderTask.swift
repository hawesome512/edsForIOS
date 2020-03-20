//
//  WorkorderTask.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

struct WorkorderTask {
    var title: String?
    var state: WorkorderTaskState = .unchecked

    init(title: String) {
        self.title = title
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
