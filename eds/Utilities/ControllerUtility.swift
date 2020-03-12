//
//  ControllerUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

class ControllerUtility {

    static func generateDeletionAlertController(with title: String) -> UIAlertController {
        let title = String(format: "delete_title".localize(with: prefixDevice), arguments: [title])
        let alertController = UIAlertController(title: title, message: "delete_info".localize(with: prefixDevice), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
}
