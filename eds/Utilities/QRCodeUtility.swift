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


    /// 生成EDS专用格式的二维码
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - param: <#param description#>
    static func generate(with type: QRCodeType, param: String) -> UIImage? {
        guard let content = EDSQRCode.getString(type: type, param: param) else {
            return nil
        }
        if let qrImage = EFQRCode.generate(
            content: content,
            backgroundColor: UIColor.systemBackground.cgColor,
            foregroundColor: edsDefaultColor.cgColor,
            watermark: UIImage(named: "wave")?.cgImage,
            watermarkMode: .scaleAspectFit) {
            return UIImage(cgImage: qrImage)
        }
        return nil
    }


    /// 解析EDS格式的二维码
    /// - Parameter image: <#image description#>
    static func recognize(with image: UIImage?) -> EDSQRCode? {
        guard let cgImage = image?.cgImage, let code = EFQRCode.recognize(image: cgImage)?.first else {
            return nil
        }
        return EDSQRCode.getCode(code)
    }
}

enum QRCodeType: Int {
    case login
    case device
    case workorder
    case alarm
}
