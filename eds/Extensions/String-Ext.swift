//
//  String-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/7.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation

extension String {
    
    //Base64解码
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    //Base64编码
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}
