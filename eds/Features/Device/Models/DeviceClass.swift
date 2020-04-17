//
//  DeviceClass.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/13.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  在首页中资产分类

import Foundation
import UIKit

enum DeviceClass: Int, CaseIterable {
    case online
    case offline
    case alarm
    case other

    func getColor() -> UIColor {
        switch self {
        case .online:
            return .systemBlue
        case .offline:
            return .systemGray
        case .alarm:
            return .systemRed
        case .other:
            return .systemGreen
        }
    }

    func getText() -> String {
        return String(describing: self).localize()
    }
}
