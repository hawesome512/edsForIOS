//
//  ShareUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


class ShareUtility {


    /// 拨打电话，使用CXCallObserver监听同行状态
    /// - Parameter number: 电话号码
    static func callPhone(to number: String) {
        let phone = "tel://\(number)"
        if let url = URL(string: phone), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Call failed")
        }
    }


    /// 发送短信
    /// - Parameters:
    ///   - number: 电话号码
    ///   - content: 短信内容
    ///   - imageData: 附带图片
    ///   - delegate: 监听发送状态
    ///   - container: 调用短信界面的容器
    static func sendSMS(to number: String, with content: String, imageData: Data?, delegate: MFMessageComposeViewControllerDelegate, in container: UIViewController?) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Device cann't send SMS")
            return
        }
        let msgController = MFMessageComposeViewController()
        msgController.body = content
        msgController.recipients = [number]
        if let data = imageData {
            msgController.addAttachmentData(data, typeIdentifier: "image/png", filename: "eds")
        }
        msgController.messageComposeDelegate = delegate
        container?.present(msgController, animated: true, completion: nil)
    }


    /// 发送邮件
    /// - Parameters:
    ///   - address: 邮箱
    ///   - title: 主题
    ///   - content: 文本
    ///   - imageData: 图片
    ///   - delegate: 监听发送状态
    ///   - container: 调用邮箱界面的容器
    static func sendMail(to address: String, title: String, content: String, imageData: Data?, delegate: MFMailComposeViewControllerDelegate, in container: UIViewController?) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Device cann't send mail")
            return
        }
        let mailController = MFMailComposeViewController()
        mailController.setSubject(title)
        mailController.setMessageBody(content, isHTML: false)
        mailController.setToRecipients([address])
        if let data = imageData {
            mailController.addAttachmentData(data, mimeType: "image/png", fileName: "eds")
        }
        mailController.mailComposeDelegate = delegate
        container?.present(mailController, animated: true, completion: nil)
    }

    //待完善
    static func sendWeChat() {

    }
}
