//
//  LoginController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/14.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import TextFieldEffects

class LoginController: UIViewController, UITextFieldDelegate {

    private let disposeBag = DisposeBag()
    private let rowHeight: CGFloat = 60
    private let textFont = UIFont.preferredFont(forTextStyle: .title3)
    //限制短信60s发送一次
    private let codeSecendLimit = 60
    //中国手机号码长度为11位
    private let phoneCount = 11
    //短信验证码长度为4位
    private let codeCount = 4

    let topImage = UIImageView()
    let codeField = HoshiTextField()
    let phoneField = HoshiTextField()
    let loginButton = UIButton()
    let codeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {

        topImage.image = UIImage(named: "login_top")
        topImage.contentMode = .scaleAspectFill
        view.addSubview(topImage)
        topImage.edgesToSuperview(excluding: .bottom)
        topImage.heightToSuperview(multiplier: 0.2)

        let bottomImage = UIImageView()
        bottomImage.image = UIImage(named: "login_bottom")
        bottomImage.contentMode = .scaleAspectFill
        view.addSubview(bottomImage)
        bottomImage.edgesToSuperview(excluding: .top)
        bottomImage.heightToSuperview(multiplier: 0.3)

        codeField.placeholder = "code".localize(with: prefixLogin)
        codeField.placeholderColor = .darkText
        codeField.placeholderFontScale = 1
        codeField.borderActiveColor = edsDefaultColor
        codeField.borderInactiveColor = .systemGray
        codeField.borderStyle = .bezel
        codeField.delegate = self
        codeField.font = textFont
        view.addSubview(codeField)
        codeField.horizontalToSuperview(insets: .horizontal(edsSpace))
        codeField.centerYToSuperview()
        codeField.height(rowHeight)
        codeField.clearButtonMode = .never
        codeField.returnKeyType = .done
        codeField.keyboardType = .numberPad

        phoneField.placeholder = "phone".localize(with: prefixLogin)
        phoneField.placeholderColor = .darkText
        phoneField.placeholderFontScale = 1
        phoneField.borderActiveColor = edsDefaultColor
        phoneField.borderInactiveColor = .systemGray
        phoneField.borderStyle = .bezel
        phoneField.delegate = self
        phoneField.font = textFont
        view.addSubview(phoneField)
        phoneField.horizontalToSuperview(insets: .horizontal(edsSpace))
        phoneField.bottomToTop(of: codeField, offset: -edsSpace)
        phoneField.height(rowHeight)
        phoneField.clearButtonMode = .whileEditing
        phoneField.returnKeyType = .done
        phoneField.keyboardType = .numberPad

        loginButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        loginButton.setTitle("login".localize(), for: .normal)
        loginButton.backgroundColor = edsDefaultColor
        loginButton.tintColor = .white
        view.addSubview(loginButton)
        loginButton.horizontalToSuperview(insets: .horizontal(edsSpace))
        loginButton.topToBottom(of: codeField, offset: edsSpace * 2)
        loginButton.height(rowHeight)

        codeButton.backgroundColor = edsDefaultColor
        codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
        view.addSubview(codeButton)
        codeButton.trailing(to: codeField)
        codeButton.centerY(to: codeField, offset: edsMinSpace / 2)
        codeButton.width(to: codeField, multiplier: 1 / 3)

    }

    
    /// 登录界面逻辑处理
    private func login() {

        codeButton.rx.tap.bind(onNext: {
            //验证输入手机号码格式
            guard let phoneNumber = self.phoneField.text, phoneNumber.verifyValidNumber(count: 11) else {
                ControllerUtility.presentAlertController(content: "phoneFormat".localize(with: prefixLogin), controller: self)
                return
            }
            //请求验证码
            Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).map { self.codeSecendLimit - $0 }.filter { $0 >= 0 }.bind(onNext: { secend in
                guard secend > 0 else {
                    self.codeButton.isEnabled = true
                    self.codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
                    return
                }
                self.codeButton.isEnabled = false
                self.codeButton.setTitle("\(secend)s", for: .normal)
                self.codeField.becomeFirstResponder()
            }).disposed(by: self.disposeBag)
            AccountUtility.sharedInstance.verifyCode(phoneNumber, controller: self)
        }).disposed(by: disposeBag)

        loginButton.rx.tap.bind(onNext: {
            //验证输入手机号码+验证码格式
            guard let phoneNumber = self.phoneField.text, phoneNumber.verifyValidNumber(count: self.phoneCount),
                let code = self.codeField.text, code.verifyValidNumber(count: self.codeCount) else {
                    ControllerUtility.presentAlertController(content: "phoneCodeFormat".localize(with: prefixLogin), controller: self)
                    return
            }
            AccountUtility.sharedInstance.verifyCode(phoneNumber, code: code, controller: self)
        }).disposed(by: disposeBag)

        AccountUtility.sharedInstance.successfulVerified.bind(onNext: { verified in
            if verified {

                let mainVC = MainController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
                self.clearInputViews()
            }
        }).disposed(by: disposeBag)
    }


    /// 验证成功后恢复输入界面
    private func clearInputViews() {
        phoneField.text = nil
        codeField.text = nil
        codeButton.isEnabled = true
        codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
