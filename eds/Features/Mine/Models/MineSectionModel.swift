//
//  MineCellModel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/29.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

enum MineSectionModel: Int, CaseIterable {
    case user
    case eds
    case exit

    func getNumberOfRows() -> Int {
        switch self {
        case .user:
            return 3
        case .eds:
            return 3
        case .exit:
            return 0
        }
    }

    static func getCellTitle(_ indexPath: IndexPath) -> String? {
        guard let section = MineSectionModel(rawValue: indexPath.section) else {
            return nil
        }
        switch section {
        case .user:
            switch indexPath.row {
            case 0:
                return "accountMember".localize()
            case 1:
                return "accountQRCode".localize()
            case 2:
                return "accountData".localize()
            default:
                return nil
            }
        case .eds:
            switch indexPath.row {
            case 0:
                return "aboutEDS".localize()
            case 1:
                return "helpEDS".localize()
            case 2:
                return "feedbackEDS".localize()
            default:
                return nil
            }
        case .exit:
            return "exitEDS".localize()
        }
    }
}
