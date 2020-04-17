//
//  PasswordViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

protocol PasswordVerifyDelegate {
    func passwordVerified()
}

class PasswordViewController: UIViewController, PasswordViewDelegate {

    var delegate: PasswordVerifyDelegate?

    func entryComplete(password: String) {
        guard let valid = validPassword else {
            return
        }
        if valid == password {
            delegate?.passwordVerified()
            dismissWithAnimation()
        } else {
            errorLabel.alpha = 1
        }
    }


    private let titleLabel = UILabel()
    private let passwordView = PasswordView()
    private let errorLabel = UILabel()
    private let disposeBag = DisposeBag()

    //正确的密码
    var validPassword: String? {
        didSet {
            //设置输入密码框数量
            if let password = validPassword {
                passwordView.lenght = password.count
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        view.backgroundColor = .white
        passwordView.delegate = self
        passwordView.textField.keyboardType = .numberPad
        passwordView.textField.becomeFirstResponder()
        view.addSubview(passwordView)
        //4⃣️个方格Label,均分width，间隔space(5个)=方格side/2
        //屏宽：13*space=4方格*2space+5间隔，passwordview宽：屏宽-左右边间隔=11*spce
        //*-口-口-口-口-*
        // 11/13=0.85,2/11=0.18
        passwordView.widthToSuperview(multiplier: 0.85)
        passwordView.heightToWidth(of: passwordView, multiplier: 0.18)
        passwordView.centerInSuperview()

        titleLabel.text = "password_title".localize()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = edsDefaultColor
        view.addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.topToSuperview(offset: edsSpace)

        errorLabel.text = "password_error".localize()
        errorLabel.textColor = .systemRed
        //输入错误提示框默认不显示，只要密码输入错误时才显示
        errorLabel.alpha = 0
        view.addSubview(errorLabel)
        errorLabel.leading(to: passwordView)
        errorLabel.topToBottom(of: passwordView, offset: edsSpace)

        let close = UIButton()
        close.rx.tap.asObservable().subscribe({ _ in
            self.dismissWithAnimation()
        }).disposed(by: disposeBag)
        view.addSubview(close)
        close.height(to: titleLabel)
        close.centerY(to: titleLabel)
        close.trailingToSuperview(offset: edsSpace)
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
    }

    private func dismissWithAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: 1000)
        })
        self.dismiss(animated: false, completion: nil)
    }
}
