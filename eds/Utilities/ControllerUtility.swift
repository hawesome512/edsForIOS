//
//  ControllerUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import YPImagePicker

class ControllerUtility {

    static func generateDeletionAlertController(with title: String) -> UIAlertController {
        let title = String(format: "delete_title".localize(with: prefixDevice), arguments: [title])
        let alertController = UIAlertController(title: title, message: "delete_info".localize(with: prefixDevice), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }

    static func generateImagePicker(maxCount: Int) -> YPImagePicker {

        var config = YPImagePickerConfiguration()
        //关闭滤镜，16:9裁剪，限制图片上传尺寸，不将裁减图片保存本地
        config.showsPhotoFilters = false
        //        config.showsCrop = .rectangle(ratio: 16 / 9)
        config.targetImageSize = .cappedTo(size: 1024)
        config.shouldSaveNewPicturesToAlbum = false
        config.library.maxNumberOfItems = maxCount
        config.library.mediaType = .photo
        config.library.defaultMultipleSelection = maxCount > 1
        return YPImagePicker(configuration: config)

    }
}
