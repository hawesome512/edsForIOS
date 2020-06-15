//
//  AccountUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import Moya
import RxCocoa

class AccountUtility {

    static let phoneKey = "login_phone"
    static let timeKey = "login_time"
    static let authorityKey = "login_authority"

    static let usernameKey = "login_username"
    static let passwordKey = "login_password"

    //随机码，62^5≈10亿种组合
    private let idCount = 5

    //单例，只允许存在一个实例
    static let sharedInstance = AccountUtility()

    //当前登录工程
    private(set) var account: Account?
    //当前工程账户拥有的子账户列表
    private(set) var phoneList: [Phone] = []
    //当前登录手机用户
    private(set) var loginedPhone: Phone?
    private(set) var successfulUpdated = BehaviorRelay<Bool?>(value: nil)

    private init() { }


    /// 登录成功后更新用户组
    /// - Parameters:
    ///   - account: <#account description#>
    ///   - phoneNumber: 1⃣️ nil:扫码临时登录 2⃣️phoneNumber为电话号码：手机快捷登录 3⃣️ 否则为系统管理员
    func loginSucceeded(_ account: Account, phoneNumber: String?) {
        self.account = account
        phoneList = account.getPhones()
        guard let phoneNumber = phoneNumber else {
            loginedPhone = Phone.inventTempPhone()
            return
        }
        if let phone = phoneList.first(where: { $0.number == phoneNumber }) {
            loginedPhone = phone
        } else {
            loginedPhone = Phone.inventAdminPhone(username: phoneNumber)
            phoneList.insert(loginedPhone!, at: 0)
        }
    }

    func verifyCode(_ phoneNumber: String, code: String? = nil, controller: UIViewController) {
        let phone = PhoneVerification(phoneNumber: phoneNumber)
        if let code = code {
            phone.code = code
        }
        EDSService.getProvider().request(.verifyPhoneLogin(phoneVerification: phone)) { result in
            switch result {
            case .success(let response):
                //手机快捷登录：验证成功
                if let account = JsonUtility.getPhoneAccount(data: response.data) {
                    self.loginSucceeded(account, phoneNumber: phoneNumber)
                    self.successfulUpdated.accept(true)
                    print("verify phone number and code success.")
                    ActionUtility.sharedInstance.addAction(.phoneLogin)
                    //登录成功后开始载入数据
                    self.loadProjData()
                    //保存登录信息:手机号，登录时间，密钥
                    UserDefaults.standard.set(phoneNumber, forKey: AccountUtility.phoneKey)
                    UserDefaults.standard.set(Date().toDateTimeString(), forKey: AccountUtility.timeKey)
                    UserDefaults.standard.set(account.authority, forKey: AccountUtility.authorityKey)
                    return
                }
                //验证失败
                if let verifiedResult = JsonUtility.getPhoneVerifyResult(data: response.data)?.0, verifiedResult.isError() {
                    self.successfulUpdated.accept(false)
                    let message = String(describing: verifiedResult.self).localize(with: prefixLogin)
                    ControllerUtility.presentAlertController(content: message, controller: controller)
                }
            case .failure:
                self.successfulUpdated.accept(false)
                let content = "failure".localize(with: prefixLogin)
                ControllerUtility.presentAlertController(content: content, controller: controller)
            }
        }
    }

    /// 用户名密码登录，含免验证、记住密码、二维码等快捷登录入口
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - password: <#password description#>
    ///   - phoneNumber: 一天内免验证登录时，不为nil
    func loadProjectAccount(username: String, password: String, controller: UIViewController, phoneNumber: String? = nil, isScan: Bool = false) {
        //获取后台服务,请求在生命周期中只有一次
        //if let _ = account { return }
        
        //因为用户id的格式为数字/工程名，使用id="/"将获取所有账户，e.g.:2/XRD、1/XKB
        let factor = EDSServiceQueryFactor(id: "/")
        EDSService.getProvider().request(.queryAccountList(factor: factor)) { result in
            switch result {
            case .success(let response):
                //后台返回数据类型[Account?]?👉[Account]
                let tempList = JsonUtility.getEDSServiceList(with: response.data, type: [Account]())
                let inputAuthority = "\(username):\(password)".toBase64()
                if let account = (tempList?.filter { $0 != nil } as! [Account]).first(where: { $0.authority == inputAuthority }) {

                    let loginText = isScan ? nil : (phoneNumber ?? username)
                    self.loginSucceeded(account, phoneNumber: loginText)
                    self.successfulUpdated.accept(true)
                    print("username:password login successed!")
                    //登录成功后开始载入数据
                    self.loadProjData()
                    //保存登录信息：用户名+密码
                    if phoneNumber == nil, isScan == false {
                        UserDefaults.standard.set(username, forKey: AccountUtility.usernameKey)
                        UserDefaults.standard.set(password, forKey: AccountUtility.passwordKey)
                        ActionUtility.sharedInstance.addAction(.passwordLogin)
                        return
                    }
                } else {
                    self.successfulUpdated.accept(false)
                    let message = "incorrectPassword".localize(with: prefixLogin)
                    ControllerUtility.presentAlertController(content: message, controller: controller)
                }
            case .failure:
                self.successfulUpdated.accept(false)
                let content = "failure".localize(with: prefixLogin)
                ControllerUtility.presentAlertController(content: content, controller: controller)
            }
        }
    }

    /// 登录验证成功后加载数据：监控点、设备、异常、工单、用户信息、能耗
    func loadProjData() {
        TagUtility.sharedInstance.loadProjectTagList()
        DeviceUtility.sharedInstance.loadProjectDeviceList()
        AlarmUtility.sharedInstance.loadProjectAlarmList()
        WorkorderUtility.sharedInstance.loadProjectWorkerorderList()
        BasicUtility.sharedInstance.loadProjectBasicInfo()
    }

    func getPhone(by name: String) -> Phone? {
        //兼容旧数据，name和phone在一起：e.g.:徐海生-100000000000
        let validName = name.separateNameAndPhone().name
        return phoneList.first { $0.name == validName }
    }

    /// 验证当前用户是否有操作权限
    func isOperable() -> Bool {
        guard let level = loginedPhone?.level else {
            return false
        }
        return level <= UserLevel.phoneOperator
    }

    //EDS Service工单、记录等数据模型需要ID
    func generateID() -> String {
        return "\(account?.id ?? NIL)-\(String.randomString(length: idCount))"
    }

    func generateImageID() -> String {
        let project = account?.id.replacingOccurrences(of: "/", with: "_")
        return "\(project ?? NIL)_\(String.randomString(length: idCount))"
    }
    
    func addPhone(_ phone: Phone){
        phoneList.append(phone)
        updatePhone()
    }
    
    func removePhone(_ phone: Phone){
        phoneList.removeAll(where: {phone.number == $0.number})
        updatePhone()
    }

    func updatePhone() {
        guard let account = self.account else {
            return
        }
        //排除虚拟手机管理员
        account.setPhone(phones: phoneList.filter { $0.level != .systemAdmin })
        EDSService.getProvider().request(.updateAccount(account: account)) { _ in }
        successfulUpdated.accept(true)
    }
    
    /// 退出前清空资源
    func clearAccount(){
        account = nil
        phoneList.removeAll()
        loginedPhone = nil
        successfulUpdated.accept(nil)
    }


    /// 退出时删除所有数据
    /// 因执行退出后将返回登录页面，必须保证二次登录时可以重新请求数据
    /// xxxUtility类中默认机制xxxList.count>0 将不再请求数据
    func prepareExitAccount() {
        //取消订阅要在clearAccount()语句前
        TagUtility.sharedInstance.unsubscribeTagValues()
        self.clearAccount()
        TagUtility.sharedInstance.clearTagList()
        DeviceUtility.sharedInstance.clearDeviceList()
        WorkorderUtility.sharedInstance.clearWorkorderList()
        AlarmUtility.sharedInstance.clearAlarmList()
        BasicUtility.sharedInstance.clearInfo()
        ActionUtility.sharedInstance.clearAction()
        EDSResourceUtility.sharedInstance.clearResource()
    }

}
