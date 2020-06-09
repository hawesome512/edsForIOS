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


    /// 用浏览器打开网页
    /// - Parameter path: <#path description#>
    static func openWeb(_ path: String) {
        //URL中可能包含中文，需转码处理
        let validPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? NIL
        if let url = URL(string: validPath), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("invalid url")
        }
    }


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
    ///   - container: 实现协议的调用短信界面的容器
    static func sendSMS(to number: String, with content: String, imageData: Data?, in container: UIViewController&MFMessageComposeViewControllerDelegate) {
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
        msgController.messageComposeDelegate = container
        container.present(msgController, animated: true, completion: nil)
    }


    /// 发送邮件
    /// - Parameters:
    ///   - address: 邮箱
    ///   - title: 主题
    ///   - content: 文本
    ///   - imageData: 图片
    ///   - container: 实现协议的调用邮箱界面的容器
    static func sendMail(to address: String, title: String, content: String, imageData: Data?, in container: UIViewController&MFMailComposeViewControllerDelegate) {
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
        mailController.mailComposeDelegate = container
        container.present(mailController, animated: true, completion: nil)
    }

    /// 截屏分享
    /// - Parameter controller: <#controller description#>
    static func sharePage(in controller: UIViewController, scrollView: UIScrollView?, sourceView: UIView) {
        if let scrollView = scrollView {
            scrollView.swContentScrollCapture{ image in
                shareImage(image: image, controller: controller, sourceView: sourceView)
            }
        } else {
            shareImage(image: controller.view.snapshot, controller: controller, sourceView: sourceView)
        }
    }
    
    static func shareImage(image:UIImage?,controller:UIViewController, sourceView: UIView){
        guard let image = image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let ppc = activityVC.popoverPresentationController {
            ppc.sourceView = sourceView
            ppc.sourceRect = sourceView.bounds
        }
        //activityVC选择“保存图片”方式将直接退回登录页面，controller(基于MainVC的导航VC将被关闭）
        controller.present(activityVC, animated: true, completion: nil)
    }
}
