//
//  PasswordController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/11.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

protocol PasswordVerifyDelegate {
    func passwordVerified()
}

class PasswordController: UIAlertController, PasswordViewDelegate {

    private let psdView = PasswordView()
    private let errorLabel = UILabel()

    var validPassword: String = "" {
        didSet {
            psdView.validValue = self.validPassword
        }
    }
    var delegate: PasswordVerifyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "password_title".localize()
        message = "\n\n\n\n\n"
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        addAction(cancelAction)

        psdView.delegate = self
        psdView.input()
        view.addSubview(psdView)
        psdView.horizontalToSuperview(insets: .horizontal(edsSpace))
        psdView.height(edsHeight)
        psdView.centerYToSuperview(offset: -edsMinSpace / 2)

        errorLabel.text = "password_error".localize()
        errorLabel.alpha = 0
        errorLabel.textColor = .systemRed
        view.addSubview(errorLabel)
        errorLabel.topToBottom(of: psdView, offset: edsMinSpace)
        errorLabel.leading(to: psdView)
    }


    func entryComplete(password: String) {
        delegate?.passwordVerified()
        dismiss(animated: true, completion: nil)
    }

    func inputting() {
        errorLabel.alpha = 0
    }

    func entryFault() {
        errorLabel.alpha = 1
    }


}



