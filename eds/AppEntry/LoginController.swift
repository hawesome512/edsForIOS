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
    private var timerDisposable: Disposable?
    
    let topImage = UIImageView()
    let bottomImage = UIImageView()
    let codeField = HoshiTextField()
    let phoneField = HoshiTextField()
    let loginButton = UIButton()
    let codeButton = UIButton()
    let titleLabel = UILabel()
    let typeLabel = UILabel()
    let typeButton = UIButton()
    let scanButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    //默认使用手机快捷登录
    private var freeVerified = false
    private var loginType = LoginType.phoneType {
        didSet {
            typeLabel.text = self.loginType.toString()
            typeButton.setTitle(self.loginType.toggle().toString(), for: .normal)
            let items = self.loginType.getItems()
            phoneField.placeholder = items[0]
            codeField.placeholder = items[1]
            switch self.loginType {
            case .phoneType:
                codeField.isSecureTextEntry = false
                codeButton.alpha = 1
                codeField.keyboardType = .numberPad
                phoneField.keyboardType = .numberPad
                phoneField.text = UserDefaults.standard.string(forKey: AccountUtility.phoneKey)
                codeField.text = nil
                checkFreeVerified()
            case .passwordType:
                codeField.isSecureTextEntry = true
                codeButton.alpha = 0
                codeField.keyboardType = .asciiCapable
                phoneField.keyboardType = .asciiCapable
                phoneField.text = UserDefaults.standard.string(forKey: AccountUtility.usernameKey)
                codeField.text = UserDefaults.standard.string(forKey: AccountUtility.passwordKey)
            default:
                break
            }
        }
    }
    
    private func initViews() {
        
        loginType = .phoneType
        
        topImage.image = UIImage(named: "login_top")
        topImage.contentMode = .scaleAspectFill
        topImage.alpha = traitCollection.verticalSizeClass == .compact ? 0 : 1
        view.addSubview(topImage)
        topImage.edgesToSuperview(excluding: .bottom)
        topImage.heightToSuperview(multiplier: 0.2)
        
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.text = "title".localize(with: prefixLogin)
        topImage.addSubview(titleLabel)
        titleLabel.centerYToSuperview()
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.trailingToSuperview(offset:edsSpace)
        
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
        loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
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
        typeButton.leading(to: loginButton)
        typeButton.topToBottom(of: loginButton, offset: edsSpace)
        
        scanButton.setTitleColor(edsDefaultColor, for: .normal)
        scanButton.setTitle(LoginType.scanType.toString(), for: .normal)
        view.addSubview(scanButton)
        scanButton.topToBottom(of: loginButton, offset: edsSpace)
        scanButton.trailing(to: loginButton)
        
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
        
        //输入手机号时验证是否可以免验证
        phoneField.rx.text.orEmpty.bind(onNext: { phone in
            if self.loginType == .phoneType {
                self.checkFreeVerified()
            }
        }).disposed(by: disposeBag)
        
        //切换登录类型
        typeButton.rx.tap.bind(onNext: {
            self.loginType = self.loginType.toggle()
            self.phoneField.resignFirstResponder()
            self.codeField.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        //请求验证码
        codeButton.rx.tap.bind(onNext: {
            //验证输入手机号码格式
            guard let phoneNumber = self.phoneField.text, phoneNumber.verifyValidNumber(count: 11) else {
                ControllerUtility.presentAlertController(content: "phoneFormat".localize(with: prefixLogin), controller: self)
                return
            }
            self.codeField.becomeFirstResponder()
            //请求验证码
            self.timerDisposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).map{ self.codeSecendLimit-$0 }.filter{ $0>=0 }.bind(onNext: { second in
                guard second > 0 else {
                    self.codeButton.isEnabled = true
                    self.codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
                    return
                }
                self.codeButton.isEnabled = false
                self.codeButton.setTitle("\(second)s", for: .normal)
            })//.disposed(by: self.disposeBag)
            AccountUtility.sharedInstance.verifyCode(phoneNumber, controller: self)
        }).disposed(by: disposeBag)
        
        //请求登录
        loginButton.rx.tap.bind(onNext: {
            
            //调试用，跳过数据请求
//            let homeVC = EnergyRankController() //EnergyConfigController()
//            homeVC.modalPresentationStyle = .fullScreen
//            self.present(homeVC, animated: true, completion: nil)
//            return
            
            //手机24小时免验证(验证码重新，即不为空，输入将重新验证）
            if self.loginType == .phoneType, self.freeVerified,
                let authorigy = UserDefaults.standard.string(forKey: AccountUtility.authorityKey)?.fromBase64(),
                let codeText = self.codeField.text, codeText.isEmpty{
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
            if self.loginType == .phoneType {
                AccountUtility.sharedInstance.verifyCode(phoneNumber, code: code, controller: self)
            } else {
                AccountUtility.sharedInstance.loadProjectAccount(username: phoneNumber, password: code, controller: self)
            }
        }).disposed(by: disposeBag)
        
        //扫码登录
        scanButton.rx.tap.bind(onNext: {
            let scanVC = ScannerViewController()
            scanVC.delegate = self
            scanVC.modalPresentationStyle = .fullScreen
            self.present(scanVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        //登录验证成功
        AccountUtility.sharedInstance.successfulUpdated.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: { verified in
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
            self.scanButton.alpha = 0
        })
    }
    
    /// 验证成功/失败后恢复输入界面
    private func clearInputViews() {
        timerDisposable?.dispose()
        codeButton.isEnabled = true
        codeButton.setTitle("acquire".localize(with: prefixLogin), for: .normal)
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        loginButton.alpha = 1
        loginIndicator.alpha = 0
        typeButton.alpha = 1
        scanButton.alpha = 1
    }
    
    @objc func scanQRCode() { }
    
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

extension LoginController: ScannerDelegate {
    
    func found(code: String) {
        var message = "invalidQRCode".localize(with: prefixLogin)
        if let edsCode = EDSQRCode.getCode(code) {
            switch edsCode.type {
            case .login:
                if edsCode.checkLoginValid() {
                    startLoginAnimating()
                    let keys = edsCode.getKeys()
                    AccountUtility.sharedInstance.loadProjectAccount(username: keys[0], password: keys[1], controller: self, phoneNumber: nil, isScan: true)
                    return
                }
            default:
                message = "requestLogin".localize(with: prefixLogin)
            }
        }
        ControllerUtility.presentAlertController(content: message, controller: self)
    }
}
