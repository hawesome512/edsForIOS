//
//  QRCodeUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/6.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import EFQRCode

class QRCodeUtility {

    static func generate(with type: QRCodeType, param: String) -> UIImage? {
        if let node = User.tempInstance.projectID, let key = User.tempInstance.authority {
            let content = "Node:\(node);Key:\(key);Type:\(type.rawValue);Param:\(param)"
            if let qrImage = EFQRCode.generate(content: content, foregroundColor: edsDefaultColor.cgColor, watermark: UIImage(named: "wave")?.cgImage, watermarkMode: .scaleAspectFit) {
                return UIImage(cgImage: qrImage)
            }
        }
        return nil
    }
}

enum QRCodeType: Int {
    case login
    case device
    case workorder
    case alarm
}
