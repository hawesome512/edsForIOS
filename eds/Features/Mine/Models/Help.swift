//
//  Help.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/5.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

struct Help {
    var name: String = ""
    var type: HelpType = .file
    var size: String = ""
    
    //格式：帮助.doc_1.1M
    init(_ info: String) {
        let infos = info.components(separatedBy: "_")
        name = infos[0]
        type = HelpType(fileName: name)
        if infos.count > 1 {
            size = infos[1]
        }
    }
}

enum HelpType {
    case vedio
    case image
    case file

    init(fileName: String) {
        let forms = ["png", "jpg", "jpeg", "bmp", "gif", "avi", "mov", "rmvb", "mp4", "3gp"]
        guard let form = fileName.components(separatedBy: ".").last?.lowercased(), let index = forms.firstIndex(of: form) else {
            self = .file
            return
        }
        if index <= 4 {
            self = .image
        } else {
            self = .vedio
        }
    }

    func getIcon() -> UIImage? {
        switch self {
        case .vedio:
            return UIImage(systemName: "film")
        case .image:
            return UIImage(systemName: "photo")
        case .file:
            return UIImage(systemName: "book")
        }
    }
}
