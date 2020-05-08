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
        let title = String(format: "delete_title".localize(), arguments: [title])
        let alertController = UIAlertController(title: title, message: "delete_info".localize(), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }

    
    /// 选择图片
    /// - Parameters:
    ///   - maxCount: <#maxCount description#>
    ///   - showCrop: <#showCrop description#>
    static func generateImagePicker(maxCount: Int, showCrop: Bool = false) -> YPImagePicker {

        var config = YPImagePickerConfiguration()
        //关闭滤镜，16:9裁剪，限制图片上传尺寸，不将裁减图片保存本地
        config.showsPhotoFilters = false
        config.onlySquareImagesFromCamera = false
        if showCrop {
            config.showsCrop = .rectangle(ratio: 16 / 9)
        }
        config.targetImageSize = .cappedTo(size: 1024)
        config.shouldSaveNewPicturesToAlbum = false
        config.library.maxNumberOfItems = maxCount
        config.library.mediaType = .photo
        config.library.defaultMultipleSelection = maxCount > 1
        return YPImagePicker(configuration: config)

    }

    static func generateSaveAlertController(navigationController: UINavigationController?) -> UIAlertController {
        let alertVC = UIAlertController(title: "cancel_alert".localize(), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel) { _ in
            navigationController?.popViewController(animated: true)
        }
        let edit = UIAlertAction(title: "edit".localize(), style: .default, handler: nil)
        alertVC.addAction(cancel)
        alertVC.addAction(edit)
        return alertVC
    }

    static func generateInputAlertController(title: String, delegate: UITextFieldDelegate?) -> UIAlertController {
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: { textField in
            textField.returnKeyType = .done
            textField.delegate = delegate
            textField.becomeFirstResponder()
        })
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        alertVC.addAction(cancel)
        return alertVC
    }

    static func presentAlertController(content: String, controller: UIViewController) {
        let alertVC = UIAlertController(title: content, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        controller.present(alertVC, animated: true, completion: nil)
    }
}
