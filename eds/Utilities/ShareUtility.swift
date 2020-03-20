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

    static func callPhone(to number: String) {
        let phone = "tel://\(number)"
        if let url = URL(string: phone), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Call failed")
        }
    }

    static func sendSMS(to number: String, with content: String, in container: ViewController&MFMessageComposeViewControllerDelegate) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Send SMS failed")
            return
        }
        let msgController = MFMessageComposeViewController()
        msgController.body = content
        msgController.recipients = [number]
        msgController.messageComposeDelegate = container
        container.present(msgController, animated: true, completion: nil)
    }

    static func sendMail(to address: String, title: String, content: String, in container: ViewController&MFMailComposeViewControllerDelegate) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Send mail failed")
            return
        }
        let mailController = MFMailComposeViewController()
        mailController.setSubject(title)
        mailController.setMessageBody(content, isHTML: false)
        mailController.setToRecipients([address])
        mailController.mailComposeDelegate = container
        container.present(mailController, animated: true, completion: nil)
    }
    
    //待完善
    static func sendWeChat(){
        
    }
}
