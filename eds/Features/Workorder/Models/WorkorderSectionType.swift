//
//  WorkorderCellType.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

//实现CI协议，遍历枚举，在table中按枚举顺序生成列表
//Int方便转换为Section<Int>
enum WorkorderSectionType: Int, CaseIterable {
    case state
    case basic
    case task
    case photo
    case info
    case message
    case qrcode

    func getSectionTitle() -> String? {
        switch self {
        case .state, .task, .photo, .message:
            return String(describing: self).localize(with: prefixWorkorder)
        default:
            return nil
        }
    }
}
