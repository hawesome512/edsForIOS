//
//  LoginController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/14.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  登录：两种登录方式：手机快捷登录，账号密码登录
//  默认（推荐）使用的是手机快捷登录
//  登录成功后自动保存用户名+密码，手机将24小时免验证登录

import UIKit
import RxSwift
import SwiftDate
import TextFieldEffects

class LoginController: UIViewController, UITextFieldDelegate {

    private let disposeBag = DisposeBag()
    private let rowHeight: CGFloat = 60
    private let textFont = UIFont.preferredFont(forTextStyle: .title3)
    //限制短信60s发送一次
    private let codeSecendLimit = 60
    //24小时（1 day）内免验证登录
    private let freeVerifyDay = 1
    private let loginIndicator = UIActivityIndicatorView()

    let topImage = UIImageView()
    let bottomImage = UIImageView()
    let codeField = HoshiTextField()
    let phoneField = HoshiTextField()
    let loginButton = UIButton()
    let codeButton = UIButton()
    let titleLabel = UILabel()
    let typeLabel = UILabel()
    let typeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    //默认使用手机快捷登录
    private var freeVerified = false
    private var usingPhone = true {
        didSet {
            if self.usingPhone {
                codeField.placeholder = "code".localize(with: prefixLogin)
                codeField.isSecureTextEntry = false
                phoneField.placeholder = "phone".localize(with: prefixLogin)
                codeButton.alpha = 1
                codeField.keyboardType = .numberPad
                phoneField.keyboardType = .numberPad
                typeLabel.text = "phoneType".localize(with: prefixLogin)
                typeButton.setTitle("passwordType".localize(with: prefixLogin), for: .normal)

                phoneField.text = UserDefaults.standard.string(forKey: AccountUtility.phoneKey)
                codeField.text = nil
                checkFreeVerified()
            } else {
                codeField.placeholder = "password".localize(with: prefixLogin)
                codeField.isSecureTextEntry = true
                phoneField.placeholder = "username".localize(with: prefixLogin)
                codeButton.alpha = 0
                codeField.keyboardType = .asciiCapable
                phoneField.keyboardType = .asciiCapable
                typeLabel.text = "passwordType".localize(with: prefixLogin)
                typeButton.setTitle("phoneType".localize(with: prefixLogin), for: .normal)
                phoneField.text = UserDefaults.standard.string(forKey: AccountUtility.usernameKey)
                codeField.text = UserDefaults.standard.string(forKey: AccountUtility.passwordKey)
            }
        }
    }

    private func initViews() {
        usingPhone = true

        topImage.image = UIImage(named: "login_top")
        topImage.contentMode = .scaleAspectFill
        topImage.alpha = traitCollection.verticalSizeClass == .compact ? 0 : 1
        view.addSubview(topImage)
        topImage.edgesToSuperview(excluding: .bottom)
        topImage.heightToSuperview(multiplier: 0.2)

        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.text = "title".localize(with: prefixLogin)
        topImage.addSubview(titleLabel)
        titleLabel.centerYToSuperview()
        titleLabel.leadingToSuperview(offset: edsSpace)

        bottomImage.image = UIImage(named: "login_bottom")
        bottomImage.contentMode = .scaleAspectFill
        bottomImage.alpha = traitCollection.verticalSizeClass == .compact ? 0 : 1
        view.addSubview(bottomImage)
        bottomImage.edgesToSuperview(excluding: .top)
        bottomImage.heightToSuperview(multiplier: 0.3)

        setDefaultField(textField: codeField)
        codeField.centerYToSuperview(offset: -edsSpace)

        setDefaultField(textField: phoneField)
        phoneField.clearButtonMode = .always
        phoneField.bottomToTop(of: codeField, offset: -edsSpace)

        typeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(typeLabel)
        typeLabel.leadingToSuperview(offset: edsSpace)
        typeLabel.bottomToTop(of: phoneField, offset: -edsSpace)

        loginButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        loginButton.setTitle("login".localize(), for: .normal)
        loginButton.backgroundColor = edsDefaultColor
        loginButton.tintColor = .white
        view.addSubview(loginButton)
        loginButton.horizontalToSuperview(insets: .horizontal(edsSpace))
        loginButton.topToBottom(of: codeField, offset: edsSpace * 2)
        loginButton.height(rowHeight)

        loginIndicator.style = .large
        loginIndicator.color = .systemRed
        loginIndicator.startAnimating()
        loginIndicator.alpha = 0
        view.addSubview(loginIndicator)
        loginIndicator.center(in: loginButton)

        typeButton.setTitleColor(edsDefaultColor, for: .normal)
        view.addSubview(typeButton)
        typeButton.centerXToSuperview()
        typeButton.topToBottom(of: loginButton, offset: edsSpace)

        codeButton.backgroundColor = edsDefaultColor
        codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
        view.addSubview(codeButton)
        codeButton.trailing(to: codeField)
        codeButton.centerY(to: codeField, offset: edsMinSpace / 2)
        codeButton.width(to: codeField, multiplier: 1 / 3)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        view.addGestureRecognizer(tapGesture)

        prepareForLogin()
    }

    @objc func tapView() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
    }

    private func setDefaultField(textField: HoshiTextField) {
        textField.placeholderColor = .systemGray
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.placeholderFontScale = 1
        textField.borderActiveColor = edsDefaultColor
        textField.borderInactiveColor = .systemGray
        textField.borderStyle = .bezel
        textField.delegate = self
        textField.font = textFont
//        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        view.addSubview(textField)
        textField.horizontalToSuperview(insets: .horizontal(edsSpace))
        textField.height(rowHeight)
    }

    /// 登录界面逻辑处理
    private func prepareForLogin() {

        phoneField.rx.text.orEmpty.bind(onNext: { phone in
            if self.usingPhone {
                self.checkFreeVerified()
            }
        }).disposed(by: disposeBag)

        typeButton.rx.tap.bind(onNext: {
            self.usingPhone = !self.usingPhone
            self.phoneField.resignFirstResponder()
            self.codeField.resignFirstResponder()
        }).disposed(by: disposeBag)

        codeButton.rx.tap.bind(onNext: {
            //验证输入手机号码格式
            guard let phoneNumber = self.phoneField.text, phoneNumber.verifyValidNumber(count: 11) else {
                ControllerUtility.presentAlertController(content: "phoneFormat".localize(with: prefixLogin), controller: self)
                return
            }
            self.codeField.becomeFirstResponder()
            //请求验证码
            Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).map { self.codeSecendLimit - $0 }.filter { $0 >= 0 }.bind(onNext: { secend in
                guard secend > 0 else {
                    self.codeButton.isEnabled = true
                    self.codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
                    return
                }
                self.codeButton.isEnabled = false
                self.codeButton.setTitle("\(secend)s", for: .normal)
            }).disposed(by: self.disposeBag)
            AccountUtility.sharedInstance.verifyCode(phoneNumber, controller: self)
        }).disposed(by: disposeBag)

        loginButton.rx.tap.bind(onNext: {
            //手机24小时免验证
            if self.freeVerified, let authorigy = UserDefaults.standard.string(forKey: AccountUtility.authorityKey)?.fromBase64() {
                self.startLoginAnimating()
                let keys = authorigy.components(separatedBy: ":")
                AccountUtility.sharedInstance.loadProjectAccount(username: keys[0], password: keys[1], controller: self, phoneNumber: self.phoneField.text)
                return
            }
            //验证输入完整性
            guard let phoneNumber = self.phoneField.text, !phoneNumber.isEmpty, let code = self.codeField.text, !code.isEmpty else {
                let content = String(format: "phoneCodeFormat".localize(with: prefixLogin), self.phoneField.placeholder!, self.codeField.placeholder!)
                ControllerUtility.presentAlertController(content: content, controller: self)
                return
            }
            self.startLoginAnimating()
            if self.usingPhone {
                AccountUtility.sharedInstance.verifyCode(phoneNumber, code: code, controller: self)
            } else {
                AccountUtility.sharedInstance.loadProjectAccount(username: phoneNumber, password: code, controller: self)
            }
        }).disposed(by: disposeBag)

        AccountUtility.sharedInstance.successfulLogined.bind(onNext: { verified in
            if verified == true {
                let mainVC = MainController()
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
                self.clearInputViews()
            } else if verified == false {
                self.clearInputViews()
            }
        }).disposed(by: disposeBag)
    }

    /// 验证是否可以使用手机免验证登录
    private func checkFreeVerified() {
        if let lastPhone = UserDefaults.standard.string(forKey: AccountUtility.phoneKey),
            let phone = phoneField.text,
            phone == lastPhone,
            let time = UserDefaults.standard.string(forKey: AccountUtility.timeKey),
            let date = DateInRegion(time, format: nil, region: .current),
            (date + freeVerifyDay.days).date > Date() {
            codeField.placeholder = "freeVerify".localize(with: prefixLogin)
            freeVerified = true
        } else {
            freeVerified = false
            codeField.placeholder = "code".localize(with: prefixLogin)
        }
    }

    private func startLoginAnimating() {
        UIView.animate(withDuration: 0.5, animations: {
            self.loginIndicator.alpha = 1
            self.loginButton.alpha = 0
            self.typeButton.alpha = 0
        })
    }

    /// 验证成功后恢复输入界面
    private func clearInputViews() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        loginButton.alpha = 1
        loginIndicator.alpha = 0
        typeButton.alpha = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.verticalSizeClass == .compact {
            topImage.alpha = 0
            bottomImage.alpha = 0
        } else {
            topImage.alpha = 1
            bottomImage.alpha = 1
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }


    /// 第一个输入框清楚，第二个自动清空
    /// - Parameter textField: <#textField description#>
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        codeField.text = nil
        return true
    }
}
